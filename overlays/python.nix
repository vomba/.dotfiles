{ }:
self: super: {
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      python-magnumclient = python-prev.python-magnumclient.overridePythonAttrs (oldAttrs: {
        doCheck = false;
      });
      python-heatclient = python-prev.python-heatclient.overridePythonAttrs (oldAttrs: {
        doCheck = false;
      });
      dogpile-cache = python-prev.dogpile-cache.overridePythonAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];
}
