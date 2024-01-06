Here is an alternative approach for trying to get Arc working. Turn your Arc into fake CUDA:

```
Total VRAM 15474 MB, total RAM 64194 MB                                                                                                                                             
Set vram state to: NORMAL_VRAM                                                                                                                                                      
Device: cuda:0 Intel(R) Arc(TM) A770 Graphics :                                                                                                                                     
VAE dtype: torch.bfloat16                                                                                                                                                           
Using pytorch cross attention       
```

This time we rip off basically the whole CUDA emulation layer is SD.next:

First clone the SD.next repo and switch to the `dev` branch: https://github.com/vladmandic/automatic

Apply this patch:

```diff
diff --git a/modules/errors.py b/modules/errors.py.bak
similarity index 100%
rename from modules/errors.py
rename to modules/errors.py.bak
diff --git a/modules/intel/ipex/hijacks.py b/modules/intel/ipex/hijacks.py
index 0dbec37393c..fdd18ff6d90 100644
--- a/modules/intel/ipex/hijacks.py
+++ b/modules/intel/ipex/hijacks.py
@@ -1,7 +1,11 @@
 import contextlib
 import torch
 import intel_extension_for_pytorch as ipex # pylint: disable=import-error, unused-import
-from modules import devices
+#from modules import devices
+
+class devices:
+    device = torch.device('xpu')
+    dtype = torch.bfloat16
 
 # pylint: disable=protected-access, missing-function-docstring, line-too-long, unnecessary-lambda, no-else-return
 
@@ -67,6 +71,7 @@ def from_numpy(ndarray):
     except Exception: # pylint: disable=broad-exception-caught
         original_torch_bmm = torch.bmm
         original_scaled_dot_product_attention = torch.nn.functional.scaled_dot_product_attention
+        raise
 
 
 # Data Type Errors:
```

Alternatively you can clone my fork with the required hacks: https://github.com/KerfuffleV2/sdnext/tree/comfyhacks — **note**: I probably won't keep this updated so patching it yourself is probably going to be more reliable.

Symlink the `modules` directory in that such that there's a `modules/` in the base of your ComfyUI repo pointing to the `modules/` in the base of the SD.next repo (with the correct branch checked out).

Apply this patch to ComfyUI:

```diff
diff --git a/comfy/model_management.py b/comfy/model_management.py
index fefd3c8..831ce49 100644
--- a/comfy/model_management.py
+++ b/comfy/model_management.py
@@ -45,12 +45,9 @@ if args.directml is not None:
     # torch_directml.disable_tiled_resources(True)
     lowvram_available = False #TODO: need to find a way to get free memory in directml before this can be enabled by default.
 
-try:
-    import intel_extension_for_pytorch as ipex
-    if torch.xpu.is_available():
-        xpu_available = True
-except:
-    pass
+import modules.intel.ipex as _ipex
+print('** IPEX init',_ipex.ipex_init())
+# xpu_available = True
 
 try:
     if torch.backends.mps.is_available():
@@ -318,7 +315,7 @@ class LoadedModel:
 
             self.model_accelerated = True
 
-        if is_intel_xpu() and not args.disable_ipex_optimize:
+        if True and not args.disable_ipex_optimize:
             self.real_model = torch.xpu.optimize(self.real_model.eval(), inplace=True, auto_kernel_selection=True, graph_mode=True)
 
         return self.real_model
@@ -639,6 +636,7 @@ def pytorch_attention_enabled():
     return ENABLE_PYTORCH_ATTENTION
 
 def pytorch_attention_flash_attention():
+    return False
     global ENABLE_PYTORCH_ATTENTION
     if ENABLE_PYTORCH_ATTENTION:
         #TODO: more reliable way of checking for flash attention?
diff --git a/comfy/utils.py b/comfy/utils.py
index f8026dd..05bdd06 100644
--- a/comfy/utils.py
+++ b/comfy/utils.py
@@ -13,7 +13,7 @@ def load_torch_file(ckpt, safe_load=False, device=None):
         sd = safetensors.torch.load_file(ckpt, device=device.type)
     else:
         if safe_load:
-            if not 'weights_only' in torch.load.__code__.co_varnames:
+            if not 'weights_only' in torch.load.__code__.co_varnames and False:
                 print("Warning torch.load doesn't support weights_only on this pytorch version, loading unsafely.")
                 safe_load = False
         if safe_load:
```

(If you knew how long it took me to track down the flash attention thing... Without that part, you'll get random corruption when sampling but only under some conditions.)

With these changes it shouldn't be necessary to do stuff like pull in the Intel/IPEX variables or set MKL stuff, I was able to remove those parts from my startup script.

The sliced attention from SD.next has two tuneables you can access via environment variable:

```python
sdpa_slice_trigger_rate = float(os.environ.get('IPEX_SDPA_SLICE_TRIGGER_RATE', 6))
attention_slice_rate = float(os.environ.get('IPEX_ATTENTION_SLICE_RATE', 4))
```

I had to set `export IPEX_ATTENTION_SLICE_RATE=3` to avoid hitting the 4GB allocation limit when doing big upscales.

So far this seems to be working for me at least as well as the previous way with the latest release of the Intel Torch stuff. I set the fallback types in `modules/intel/ipex/hijacks.py` to `torch.bfloat16` but I don't really know what the optimal type would be. Seems to work. (That's what it uses when no type is specified, I think.)

For reference, here's my startup script:

```shell
#!/bin/bash
source .venv/bin/activate
export IPEX_ATTENTION_SLICE_RATE=3
nice -n 10 ipexrun xpu main.py --preview-method taesd --use-pytorch-cross-attention --disable-xformers --bf16-vae --bf16-unet "$@"
```

