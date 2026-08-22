let
  lily = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ72u+rxADmeVHX0xyj9CslY9f6cwu2zu8Qy022mfitf";
  users = [ lily ];

  snatcher = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+RhxPzYSA1maIqgb/lDskJGtvqwI0tFoLCmMh0WNod";
  systems = [ snatcher ];
in
{
  "rclone-ndcfiles.age".publicKeys = users ++ systems;
}