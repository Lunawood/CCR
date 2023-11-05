Require Import Coqlib.
Require Export ZArith.
Require Import String.
Require Import PCM.
Require Export AList.

Set Implicit Arguments.

Local Open Scope nat_scope.

Notation gname := string (only parsing). (*** convention: not capitalized ***)
Notation mname := string (only parsing). (*** convention: capitalized ***)


Fixpoint _find_idx {A} (f: A -> bool) (l: list A) (acc: nat): option (nat * A) :=
  match l with
  | [] => None
  | hd :: tl => if (f hd) then Some (acc, hd) else _find_idx f tl (S acc)
  end
.

Definition find_idx {A} (f: A -> bool) (l: list A): option (nat * A) := _find_idx f l 0.

Notation "'do' ' X <- A ; B" := (o_bind A (fun _x => match _x with | X => B end))
                                  (at level 200, X pattern, A at level 100, B at level 200)
                                : o_monad_scope.

Lemma find_idx_red {A} (f: A -> bool) (l: list A):
  find_idx f l =
  match l with
  | [] => None
  | hd :: tl =>
    if (f hd)
    then Some (0%nat, hd)
    else
      do (n, a) <- find_idx f tl;
      Some (S n, a)
  end.
Proof.
  unfold find_idx. generalize 0. induction l; ss.
  i. des_ifs; ss.
  - rewrite Heq0. ss.
  - rewrite Heq0. specialize (IHl (S n)). rewrite Heq0 in IHl. ss.
Qed.


Module SkEnv.

  Notation mblock := nat (only parsing).
  Notation ptrofs := Z (only parsing).

  Record t: Type := mk {
    blk2id: mblock -> option gname;
    id2blk: gname -> option mblock;
  }
  .

  Definition wf (ske: t): Prop :=
    forall id blk, ske.(id2blk) id = Some blk <-> ske.(blk2id) blk = Some id.

End SkEnv.






Require Import Orders.
Require Import PCM.
From compcertip Require Import Maps Clightdefs.

Module Sk.
  Class ld: Type := mk {
    t:> Type;
    sem: Type;
    unit: t;
    add: t -> t -> t;
    canon: t -> sem;
    wf: t -> Prop;
    add_comm: forall a b,
      canon (add a b) = canon (add b a);
    add_assoc: forall a b c,
      canon (add a (add b c)) = canon (add (add a b) c);
    add_unit_l: forall a, canon (add unit a) = canon a;
    add_unit_r: forall a, canon (add a unit) = canon a;
    wf_comm: forall a b, wf (add a b) -> wf (add b a);
    unit_wf: wf unit;
    wf_mon: forall a b, wf (add a b) -> wf a;
    extends := fun a b => exists ctx, canon (add a ctx) = b;
  }
  .

  Section SK.
  Context {M: RA.t}.

  Definition _add : option RA.car -> option RA.car -> option RA.car :=
    fun optx opty =>
      match optx, opty with
      | Some x, Some y => Some (RA.add x y)
      | Some x, None => Some x
      | None, Some y => Some y
      | None, None => None
      end.

  Program Instance globalenv : ld := {
    t := PTree.t RA.car;
    sem := alist string RA.car;
    unit := PTree.empty RA.car;
    add := PTree.combine _add;
    canon:= (List.map (map_fst string_of_ident)) ∘ (@PTree.elements RA.car);
    wf := fun m => forall p x, PTree.get p m = Some x -> RA.wf x;
  }.
  Next Obligation.
  Proof.
    unfold add. erewrite PTree.combine_commut; et.
    i. unfold _add. des_ifs. f_equal. apply RA.add_comm. 
  Qed.
  Next Obligation.
  Proof.
    f_equal. apply PTree.elements_extensional.
    i. repeat (rewrite PTree.gcombine; et).
    unfold _add. des_ifs. f_equal. apply RA.add_assoc.
  Qed.
  Next Obligation.
  Proof.
    f_equal. apply PTree.elements_extensional.
    i. rewrite PTree.xgcombine_r; et.
    unfold _add. des_ifs.
  Qed.
  Next Obligation.
  Proof.
    f_equal. apply PTree.elements_extensional.
    i. repeat (rewrite PTree.gcombine; et).
    unfold _add. des_ifs.
    all: rewrite PTree.gempty in Heq0; clarify.
  Qed.
  Next Obligation.
  Proof.
    erewrite PTree.combine_commut in H0; try eapply H; et.
    i. unfold _add. des_ifs. f_equal. apply RA.add_comm.
  Qed.
  Next Obligation.
  Proof.
    rewrite PTree.gempty in H. ss.
  Qed.
  Next Obligation.
  Proof.
    specialize (H p). rewrite PTree.gcombine in H; et.
    rewrite H0 in H. destruct (b ! p).
    - hexploit H; et. eapply RA.wf_mon.
    - hexploit H; et.
  Qed.

  Local Existing Instance gdefs.

  Definition sort_add_comm sk0 sk1
             (WF: wf (add sk0 sk1))
    :
      sort (add sk0 sk1) = sort (add sk1 sk0).
  Proof.
    eapply SkSort.sort_add_comm. eapply WF.
  Qed.

  Definition sort_wf sk (WF: wf sk):
    wf (sort sk).
  Proof.
    ss. eapply Permutation.Permutation_NoDup; [|apply WF].
    eapply Permutation.Permutation_map.
    eapply SkSort.sort_permutation.
  Qed.

  (*** TODO: It might be nice if Sk.t also constitutes a resource algebra ***)
  (*** At the moment, List.app is not assoc/commutative. We need to equip RA with custom equiv. ***)

  Definition load_skenv (sk: t): (SkEnv.t) :=
    let n := List.length sk in
    {|
      SkEnv.blk2id := fun blk => do '(gn, _) <- (List.nth_error sk blk); Some gn;
      SkEnv.id2blk := fun id => do '(blk, _) <- find_idx (fun '(id', _) => string_dec id id') sk; Some blk
    |}
  .

  Lemma load_skenv_wf
        sk
        (WF: wf sk)
    :
      <<WF: SkEnv.wf (load_skenv sk)>>
  .
  Proof.
    r in WF.
    rr. split; i; ss.
    - uo; des_ifs.
      + f_equal. ginduction sk; ss. i. inv WF.
        rewrite find_idx_red in Heq1. des_ifs; ss.
        { des_sumbool. subst. ss. clarify. }
        des_sumbool. uo. des_ifs. destruct p. ss.
        hexploit IHsk; et.
      + exfalso. ginduction sk; ss. i. inv WF.
        rewrite find_idx_red in Heq2. des_ifs; ss.
        des_sumbool. uo. des_ifs. destruct p. ss.
        hexploit IHsk; et.
    - ginduction sk; ss.
      { i. uo. ss. destruct blk; ss. }
      i. destruct a. inv WF. uo. destruct blk; ss; clarify.
      {  rewrite find_idx_red. uo. des_ifs; des_sumbool; ss. }
      hexploit IHsk; et. i.
      rewrite find_idx_red. uo. des_ifs; des_sumbool; ss. exfalso.
      subst. clear - Heq1 H2. ginduction sk; ss. i.
      rewrite find_idx_red in Heq1. des_ifs; des_sumbool; ss; et.
      uo. des_ifs. destruct p. eapply IHsk; et.
  Qed.

  Definition incl (sk0 sk1: Sk.t): Prop :=
    forall gn gd (IN: List.In (gn, gd) sk0),
      List.In (gn, gd) sk1.

  Program Instance incl_PreOrder: PreOrder incl.
  Next Obligation.
  Proof.
    ii. ss.
  Qed.
  Next Obligation.
  Proof.
    ii. eapply H0. eapply H. ss.
  Qed.

  Lemma sort_incl sk
    :
      incl sk (sort sk).
  Proof.
    ii. eapply Permutation.Permutation_in; [|apply IN].
    eapply SkSort.sort_permutation.
  Qed.

  Lemma sort_incl_rev sk
    :
      incl (sort sk) sk.
  Proof.
    ii. eapply Permutation.Permutation_in; [|apply IN].
    symmetry. eapply SkSort.sort_permutation.
  Qed.

  Definition incl_env (sk0: Sk.t) (skenv: SkEnv.t): Prop :=
    forall gn gd (IN: List.In (gn, gd) sk0),
    exists blk, <<FIND: skenv.(SkEnv.id2blk) gn = Some blk>>.

  Lemma incl_incl_env sk0 sk1
        (INCL: incl sk0 sk1)
    :
      incl_env sk0 (load_skenv sk1).
  Proof.
    ii. exploit INCL; et. i. ss. uo. des_ifs; et.
    exfalso. clear - x0 Heq0. ginduction sk1; et.
    i. ss. rewrite find_idx_red in Heq0. des_ifs.
    des_sumbool. uo.  des_ifs. des; clarify.
    eapply IHsk1; et.
  Qed.

  Lemma in_env_in_sk :
    forall sk blk symb
      (FIND: SkEnv.blk2id (Sk.load_skenv sk) blk = Some symb),
    exists def, In (symb, def) sk.
  Proof.
    i. unfold SkEnv.blk2id. ss.
    uo. des_ifs. des; clarify.
    eapply nth_error_In in Heq0. et.
  Qed.

  Lemma in_sk_in_env :
    forall sk def symb
           (IN: In (symb, def) sk),
    exists blk, SkEnv.blk2id (Sk.load_skenv sk) blk = Some symb.
  Proof.
    i. unfold SkEnv.blk2id. ss.
    uo. eapply In_nth_error in IN. des.
    eexists. rewrite IN. et.
  Qed.

  Lemma env_range_some :
    forall sk blk
      (BLKRANGE : blk < Datatypes.length sk),
      <<FOUND : exists symb, SkEnv.blk2id (Sk.load_skenv sk) blk = Some symb>>.
  Proof.
    i. depgen sk. induction blk; i; ss; clarify.
    { destruct sk; ss; clarify.
      { lia. }
      uo. destruct p. exists s. ss. }
    destruct sk; ss; clarify.
    { lia. }
    apply lt_S_n in BLKRANGE. eapply IHblk; eauto.
  Qed.

  Lemma env_found_range :
    forall sk symb blk
      (FOUND : SkEnv.id2blk (Sk.load_skenv sk) symb = Some blk),
      <<BLKRANGE : blk < Datatypes.length sk>>.
  Proof.
    induction sk; i; ss; clarify.
    uo; des_ifs. destruct p0. rewrite find_idx_red in Heq0. des_ifs.
    { apply Nat.lt_0_succ. }
    destruct blk.
    { apply Nat.lt_0_succ. }
    uo. des_ifs. destruct p. ss. clarify. apply lt_n_S. eapply IHsk; eauto.
    instantiate (1:=symb). rewrite Heq0. ss.
  Qed.

End Sk.
