{ swayfx }:
final: prev: {
  swayfx = swayfx.packages.${final.system}.default;
}