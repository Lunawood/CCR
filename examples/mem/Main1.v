Require Import Coqlib.
Require Import ITreelib.
Require Import Universe.
Require Import STS.
Require Import Behavior.
Require Import ModSem.
Require Import Skeleton.
Require Import PCM.
Require Import HoareDef.
Require Import TODOYJ.

Generalizable Variables E R A B C X Y Σ.

Set Implicit Arguments.



Require Import Mem1.


(* Notation "'hCall2' fn varg" := *)
(*   (marg <- trigger (Choose _);; vret <- trigger (hCall fn marg varg);; vret <- vret↓?;; Ret vret) *)
(*     (at level 60). *)
(* Definition hCall' {X} (fn: string) (varg: Any.t): itree (hCallE +' eventE) X := *)
(*   marg <- trigger (Choose _);; vret <- trigger (hCall fn marg varg);; vret <- vret↓?;; Ret vret *)
(* . *)
  (* marg <- trigger (Choose _);; trigger (hCall fn marg varg) >>= ((?) <*> (↓)) *)

Section PROOF.

  Context `{Σ: GRA.t}.
  Context `{@GRA.inG memRA Σ}.

  (***
        void* x = malloc(1);
        *x = 42;
        unknown_call(x);
        y = *x;
        return y; ~~~> return 42;
   ***)

  Definition mainBody: list val -> itree (hCallE +' pE +' eventE) val :=
    fun _ =>
      x <- trigger (hCall true "alloc" [Vint 1]↑);; x <- x↓?;;
      trigger (hCall true "store" [x ; Vint 42]↑);;
      (* trigger (Call "unknown_call" [x]);; *)
      trigger (hCall true "load" [x]↑);;
      Ret (Vint 42)
  .

  (*** main's view on stb ***)
  Definition main_spec: fspec := mk_simple "Main" (X:=unit) (fun _ _ o _ => o = ord_top) top3.

  Definition MainStb: list (gname * fspec).
    eapply (Seal.sealing "stb").
    apply [("main", main_spec)].
  Defined.

  Definition MainSbtb: list (gname * fspecbody) := [("main", mk_specbody main_spec mainBody)].

  (***
Possible improvements:
(1) "exists b" in "alloc"
      --> it would be better if we can just use "b" in the remaning of the code.
(2) (fun x varg rarg => k x)
      --> We know what "x" will be, so why not just write "(fun varg rarg => k x)"?.
          In other words, the "Choose" in the code is choosing "x", but we want to choose "x" when writing the spec.
   ***)

  Definition MainSem: ModSem.t := {|
    ModSem.fnsems := List.map (fun '(fn, body) => (fn, fun_to_tgt (MemStb ++ MainStb) fn body)) MainSbtb;
    ModSem.mn := "Main";
    ModSem.initial_mr := ε;
    ModSem.initial_st := tt↑;
  |}
  .

  Definition Main: Mod.t := {|
    Mod.get_modsem := fun _ => MainSem;
    Mod.sk := List.map (fun '(n, _) => (n, Sk.Gfun)) MainSbtb;
  |}
  .

End PROOF.
Global Hint Unfold MainStb: stb.
