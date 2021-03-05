Require Import Coqlib.
Require Import ITreelib.
Require Import Universe.
Require Import STS.
Require Import Behavior.
Require Import ModSem.
Require Import Skeleton.
Require Import PCM.
Require Import TODO.

Generalizable Variables E R A B C X Y Σ.

Set Implicit Arguments.



Section PROOF.

  Context `{Σ: GRA.t}.

  (***
    f(n) := if (n == 0) then 0 else (n + g(n-1))
  ***)
  Definition fF: list val -> itree Es val :=
    fun varg =>
      `n: Z <- (pargs [Tint] varg)?;;
      if dec n 0%Z
      then Ret (Vint 0)
      else
        (m <- ccall "g" [Vint (n - 1)];;
        r <- (vadd (Vint n) m)?;;
        Ret r).

  Definition FSem: ModSem.t := {|
    ModSem.fnsems := [("f", cfun fF)];
    ModSem.initial_mrs := [("F", (ε, tt↑))];
  |}
  .

  Definition F: Mod.t := {|
    Mod.get_modsem := fun _ => FSem;
    Mod.sk := [("f", Sk.Gfun)];
  |}
  .
End PROOF.