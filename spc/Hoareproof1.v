Require Import Coqlib.
Require Import STS.
Require Import Behavior.
Require Import ModSem.
Import ModSemL.
Require Import Skeleton.
Require Import PCM.
Require Import Any.
Require Import HoareDef.
Require Import SimSTS.
Require Import SimGlobal.
Require Import HoareDef.
From Ordinal Require Import Ordinal Arithmetic.

Set Implicit Arguments.
















Lemma add_le_lt: forall x0 x1 y0 y1, (x0 <= x1)%ord -> (y0 < y1)%ord -> (x0 + y0 < x1 + y1)%ord.
Proof.
  i.
  eapply Ord.le_lt_lt.
  - eapply OrdArith.le_add_l; et.
  - eapply OrdArith.lt_add_r; et.
Qed.

Lemma add_le_le: forall x0 x1 y0 y1, (x0 <= x1)%ord -> (y0 <= y1)%ord -> (x0 + y0 <= x1 + y1)%ord.
Proof.
  i.
  etrans.
  - eapply OrdArith.le_add_r; et.
  - eapply OrdArith.le_add_l; et.
Qed.

Lemma mul_le_lt: forall x0 x1 y0 y1, (0 < x1)%ord -> (x0 <= x1)%ord -> (y0 < y1)%ord -> (x0 * y0 < x1 * y1)%ord.
Proof.
  i.
  eapply Ord.le_lt_lt.
  - eapply OrdArith.le_mult_l; et.
  - eapply OrdArith.lt_mult_r; et.
Qed.

Lemma mult_le_le: forall x0 x1 y0 y1, (x0 <= x1)%ord -> (y0 <= y1)%ord -> (x0 * y0 <= x1 * y1)%ord.
Proof.
  i.
  etrans.
  - eapply OrdArith.le_mult_l; et.
  - eapply OrdArith.le_mult_r; et.
Qed.

Lemma expn_pos: forall base o, (1 <= base ^ o)%ord.
Proof. i. rewrite Ord.from_nat_S. eapply Ord.S_supremum. eapply OrdArith.expn_pos. Qed.

Lemma add_one_lt: forall o0 o1, (o0 < o1)%ord -> (o0 + 1 <= o1)%ord.
Proof.
  i.
  rewrite Ord.from_nat_S.
  rewrite OrdArith.add_S.
  rewrite OrdArith.add_O_r.
  eapply Ord.S_supremum; et.
Qed.






Module Type PARAM.
  Parameter c: Ord.t.
  Parameter d: Ord.t.
  Parameter e: Ord.t.
  Parameter f: Ord.t.
End PARAM.

Module Construction (P: PARAM).
  Include P.

  Section CONSTRUCTION.

  Let alpha := (f + 3 + d + e)%ord.
  (* Let alpha_d: ((1 + d) <= alpha)%ord. *)
  (* Proof. unfold alpha. rewrite <- OrdArith.add_O_r at 1. eapply add_le_le; try refl. eapply Ord.O_is_O. Qed. *)
  Let alpha_e: (e <= alpha)%ord.
  Proof.
    unfold alpha.
    eapply OrdArith.add_base_r.
    (* etrans; [eapply OrdArith.add_base_l|]. *)
    (* etrans; [eapply OrdArith.add_base_r|]. *)
    (* rewrite <- OrdArith.add_assoc. rewrite OrdArith.add_assoc. refl. *)
  Qed.

  Let alpha_d: (f + 3 + d <= alpha)%ord.
  Proof.
    unfold alpha.
    eapply OrdArith.add_base_l.
    (* etrans; [eapply OrdArith.add_base_l|]. *)
    (* etrans; [eapply OrdArith.add_base_r|]. *)
    (* rewrite <- OrdArith.add_assoc. *)
    (* eapply add_le_le; try refl. *)
    (* rewrite <- OrdArith.add_assoc. *)
    (* refl. *)
  Qed.

  Definition myF (o0: Ord.t): Ord.t := ((alpha * kappa + c) ^ (o0 + 1))%ord.
  Definition myG (o0 m0: Ord.t): Ord.t := ((alpha * kappa + c) ^ (o0) * alpha * m0)%ord.
  Definition myH (o0: Ord.t): Ord.t := ((alpha * kappa + c) ^ (o0) * 3)%ord.

  (***
                         (myG o0 kappa + d <= myF o0)
  (AM: (m1 < m0)%ord) -> (myG o0 m1 + myH o0 + c <= myG o0 m0)%ord
  (O: (o1 < o0)%ord)  -> (myF o1 + e <= myH o0)%ord
   ***)

  Let NZERO: (Ord.O < alpha * kappa + c)%ord.
  Proof.
    unfold alpha.

    assert(T: (1 < f + 3 + d + e)%ord).
    { assert(U: (1 + 1 <= (Ord.from_nat 3))%ord).
      { rewrite <- OrdArith.add_from_nat. ss. eapply OrdArith.le_from_nat; et. }
      eapply Ord.lt_le_lt; cycle 1.
      { rewrite <- U. refl. }
      rewrite ! OrdArith.add_assoc.
      eapply Ord.lt_le_lt; cycle 1.
      { eapply OrdArith.add_base_r. }
      eapply OrdArith.add_lt_l.
      rewrite Ord.from_nat_S at 1.
      eapply Ord.lt_le_lt.
      { instantiate (1:=1%ord). rewrite Ord.from_nat_S. eapply Ord.S_pos. }
      { rewrite Ord.from_nat_S. eapply OrdArith.add_base_l. }
    }

    eapply Ord.lt_le_lt; cycle 1.
    { eapply OrdArith.add_base_l. }
    rewrite <- OrdArith.mult_1_r.
    eapply Ord.le_lt_lt; cycle 1.
    { instantiate (1:=((f + 3 + d + e) * 1)%ord).
      eapply OrdArith.lt_mult_r.
      - eauto with ord_kappa.
      - rewrite <- T. replace (Ord.from_nat 1) with (Ord.S Ord.O) by ss. eapply Ord.S_pos. }
    eapply mult_le_le.
    - eapply Ord.O_is_O.
    - refl.
  Qed.

  Global Program Instance myG_proper: Proper (Ord.le ==> Ord.le ==> Ord.le) (myG).
  Next Obligation.
    ii. unfold myG.
    rewrite <- H0.
    eapply mult_le_le; et; try refl.
    eapply mult_le_le; et; try refl.
    rewrite <- H. refl.
  Qed.

  Theorem my_thm1: forall o0, (myG o0 kappa + c <= myF o0)%ord.
  Proof.
    i. unfold myF, myG, myH.
    rewrite OrdArith.expn_add; et.
    rewrite OrdArith.expn_1_r; et.
    rewrite OrdArith.mult_dist.
    eapply add_le_le.
    - rewrite <- OrdArith.mult_assoc. refl.
    - rewrite <- (OrdArith.mult_1_l) at 1. eapply mult_le_le; try refl. eapply expn_pos.
    (* OrdArith.add *)
    (* OrdArith.mult *)
    (* OrdArith.expn *)
  Qed.

  Theorem my_thm3
          o0 o1
          (O: (o1 < o0)%ord)
    :
      (myF o1 + e <= myH o0)%ord
  .
  Proof.
    unfold myF, myG, myH.
    eapply add_one_lt in O.
    rewrite <- O.
    rewrite OrdArith.expn_add; et.
    rewrite OrdArith.expn_1_r; et.
    assert(T: (1 + 1 <= 3)%ord).
    { rewrite <- OrdArith.add_from_nat. ss. eapply OrdArith.le_from_nat; et. }
    rewrite <- T.
    rewrite OrdArith.mult_dist with (o2:=1).
    rewrite OrdArith.mult_1_r.
    eapply add_le_le; try refl.
    rewrite <- (OrdArith.mult_1_l) at 1.
    eapply mult_le_le.
    { eapply expn_pos. }
    rewrite <- alpha_e.
    etrans; [|eapply OrdArith.add_base_l].
    rewrite <- (OrdArith.mult_1_r) at 1.
    eapply mult_le_le; try refl.
    eapply Ord.lt_le.
    eauto with ord_kappa.
  Qed.

  Theorem my_thm2
          o0 m0 m1
          (AM: (m1 < m0)%ord)
    :
      (myG o0 m1 + f + myH o0 + d <= myG o0 m0)%ord
  .
  Proof.
    unfold myF, myG, myH.
    eapply add_one_lt in AM.
    rewrite <- AM.
    rewrite OrdArith.mult_dist.
    rewrite OrdArith.mult_1_r.
    rewrite OrdArith.add_assoc.
    rewrite OrdArith.add_assoc.
    eapply add_le_le; try refl.
    rewrite <- alpha_d at 3.
    rewrite OrdArith.mult_dist.
    rewrite OrdArith.mult_dist.
    rewrite <- OrdArith.add_assoc.
    eapply add_le_le; try refl; cycle 1.
    { rewrite <- (OrdArith.mult_1_l) at 1. eapply mult_le_le; try refl. eapply expn_pos. }
    eapply add_le_le; try refl; cycle 1.
    { rewrite <- (OrdArith.mult_1_l) at 1. eapply mult_le_le; try refl. eapply expn_pos. }
  Qed.

  End CONSTRUCTION.

End Construction.


Module MyParam <: PARAM.
  Definition d: Ord.t := 50%ord.
  Definition c: Ord.t := (d + 30)%ord.
  Definition e: Ord.t := 50%ord.
  Definition f: Ord.t := (d + 10)%ord.
End MyParam.

Module C := (Construction MyParam).

















Inductive opair: Type := mk_opair { ofst: Ord.t; osnd: Ord.t }.
(* Definition opair_lt: opair -> opair -> Prop := fun '(mk_opair x0 x1) '(mk_opair y0 y1) => (x0 < y0)%ord \/ (x0 == y0 /\ x1 < y1)%ord. *)
Inductive opair_lt: opair -> opair -> Prop :=
| intro_opair_lt
    x0 x1 y0 y1
    (LT: (x0 < y0)%ord \/ (x0 == y0 /\ x1 < y1)%ord)
  :
    opair_lt (mk_opair x0 x1) (mk_opair y0 y1)
.
Theorem wf_opair_lt: well_founded opair_lt.
Proof.
  ii. destruct a.
  revert osnd0. pattern ofst0. eapply well_founded_ind. { eapply Ord.lt_well_founded. } clear ofst0. intros ? IH0.
  intro. generalize dependent x. pattern osnd0. eapply well_founded_ind. { eapply Ord.lt_well_founded. } clear osnd0. intros ? IH1.
  econs. i. inv H. des.
  { eapply IH0; et. }
  { eapply IH1; et. i. eapply IH0; et. rewrite <- LT. ss. }
Qed.











Section CANCEL.

  (*** execute following commands in emacs (by C-x C-e)
     (progn (highlight-phrase "Any" 'hi-red-b) (highlight-phrase "Any_src" 'hi-green-b) (highlight-phrase "Any_tgt" 'hi-blue-b)
            (highlight-phrase "Any_mid" 'hi-light-green-b)
            (highlight-phrase "Y" 'hi-green-b) (highlight-phrase "Z" 'hi-green-b)) ***)
  Let Any_src := Any.t. (*** src argument (e.g., List nat) ***)
  Let Any_mid := Any.t. (*** src argument (e.g., List nat) ***)
  Let Any_tgt := Any.t. (*** tgt argument (i.e., list val) ***)



  Context `{Σ: GRA.t}.

  Variable mds: list SMod.t.

  Let sk: Sk.t := Sk.sort (fold_right Sk.add Sk.unit (List.map SMod.sk mds)).
  (* Let skenv: SkEnv.t := Sk.load_skenv sk. *)
  Let mss: list SModSem.t := (List.map ((flip SMod.get_modsem) sk) mds).
  Let sbtb: list (gname * fspecbody) := (List.flat_map (SModSem.fnsems) mss).
  Let _stb: list (gname * fspec) := List.map (fun '(fn, fs) => (fn, fs.(fsb_fspec))) sbtb.

  Variable stb: gname -> option fspec.
  Hypothesis STBCOMPLETE:
    forall fn fsp (FIND: alist_find fn _stb = Some fsp), stb fn = Some fsp.
  Hypothesis STBSOUND:
    forall fn (FIND: alist_find fn _stb = None),
      (<<NONE: stb fn = None>>) \/ (exists fsp, <<FIND: stb fn = Some fsp>> /\ <<TRIVIAL: forall mn x arg_src arg_tgt o r (PRE: fsp.(precond) mn x arg_src arg_tgt o r), o = ord_top>>).


  Let mds_mid2: list Mod.t := List.map (SMod.to_mid2 stb) mds.
  Let mds_mid: list Mod.t := List.map (SMod.to_mid stb) mds.



  Let W: Type := p_state.
  (* Let wf: Ord.t -> W -> W -> Prop := top3. *)

  Opaque EventsL.interp_Es.

  Let ms_mid2: ModSemL.t := ModL.enclose (Mod.add_list mds_mid2).
  Let ms_mid: ModSemL.t := ModL.enclose (Mod.add_list mds_mid).

  Let p_mid2 := ModSemL.prog ms_mid2.
  Let p_mid := ModSemL.prog ms_mid.

  Ltac _ord_step := eapply add_le_lt; [refl|eapply OrdArith.lt_from_nat; ss].

  Ltac _step tac :=
    match goal with
    (*** terminal cases ***)
    | [ |- gpaco6 _ _ _ _ _ _ _ _ (triggerUB >>= _) _ ] =>
      unfold triggerUB; mred; _step tac; ss; fail
    | [ |- gpaco6 _ _ _ _ _ _ _ _ (triggerNB >>= _) _ ] =>
      exfalso
    | [ |- gpaco6 _ _ _ _ _ _ _ _ _ (triggerUB >>= _) ] =>
      exfalso
    | [ |- gpaco6 _ _ _ _ _ _ _ _ _ (triggerNB >>= _) ] =>
      unfold triggerNB; mred; _step tac; ss; fail

    (*** assume/guarantee ***)
    | [ |- gpaco6 _ _ _ _ _ _ _ _ (assume ?P ;;; _) _ ] =>
      let tvar := fresh "tmp" in
      let thyp := fresh "TMP" in
      remember (assume P) as tvar eqn:thyp; unfold assume in thyp; subst tvar
    | [ |- gpaco6 _ _ _ _ _ _ _ _ (guarantee ?P ;;; _) _ ] =>
      let tvar := fresh "tmp" in
      let thyp := fresh "TMP" in
      remember (guarantee P) as tvar eqn:thyp; unfold guarantee in thyp; subst tvar
    | [ |- gpaco6 _ _ _ _ _ _ _ _ _ (assume ?P ;;; _) ] =>
      let tvar := fresh "tmp" in
      let thyp := fresh "TMP" in
      remember (assume P) as tvar eqn:thyp; unfold assume in thyp; subst tvar
    | [ |- gpaco6 _ _ _ _ _ _ _ _ _ (guarantee ?P ;;; _) ] =>
      let tvar := fresh "tmp" in
      let thyp := fresh "TMP" in
      remember (guarantee P) as tvar eqn:thyp; unfold guarantee in thyp; subst tvar

    (*** default cases ***)
    | _ =>
      (gstep; tac; econs; auto; try (_ord_step);
       (*** some post-processing ***)
       i;
       try match goal with
           | [ |- (eq ==> _)%signature _ _ ] =>
             let v_src := fresh "v_src" in
             let v_tgt := fresh "v_tgt" in
             intros v_src v_tgt ?; subst v_tgt
           end)
    end
  .

  Ltac steps := repeat (mred; try _step ltac:(eapply simg_safe_spec); des_ifs_safe).
  Ltac steps_strong := repeat (mred; try (_step ltac:(idtac)); des_ifs_safe).

  Lemma stb_find_iff_aux fn
    :
      ((<<NONE: alist_find fn _stb = None>>) /\
       (<<FINDSRC: alist_find fn (fnsems ms_mid2) = None>>) /\
       (<<FINDMID: alist_find fn (fnsems ms_mid) = None>>)) \/

      (exists md (f: fspecbody),
          (<<SOME: alist_find fn _stb = Some (f: fspec)>>) /\
          (<<FINDSRC: alist_find fn (fnsems ms_mid2) =
                      Some (transl_all (T:=_)
                              (SModSem.mn
                                 (SMod.get_modsem md sk))
                              ∘ fun_to_mid2 (fsb_body f))>>) /\
          (<<FINDMID: alist_find fn (fnsems ms_mid) =
                      Some (transl_all (T:=_)
                              (SModSem.mn
                                 (SMod.get_modsem md sk))
                              ∘ fun_to_mid stb (fsb_body f))>>)).
  Proof.
    unfold ms_mid2, ms_mid, mds_mid, mds_mid2, SMod.to_mid2, SMod.to_mid.
    rewrite SMod.transl_fnsems. rewrite SMod.transl_fnsems. fold sk.
    unfold _stb at 1 2. unfold sbtb, mss. rewrite alist_find_map.
    generalize mds. induction mds0; ss; auto. rewrite ! alist_find_app_o.
    erewrite ! SMod.red_do_ret2. rewrite ! alist_find_map. uo.
    destruct (alist_find fn (SModSem.fnsems (SMod.get_modsem a sk))) eqn:FIND.
    { right. esplits; et. }
    des.
    { left. esplits; et. }
    { right. esplits; et. }
  Qed.

  Lemma stb_find_iff fn
    :
      ((<<NONE: stb fn = None>> \/ (exists fsp, <<FIND: stb fn = Some fsp>> /\ <<TRIVIAL: forall mn x arg_src arg_tgt o r (PRE: fsp.(precond) mn x arg_src arg_tgt o r), o = ord_top>>)) /\
       (<<FINDSRC: alist_find fn (fnsems ms_mid2) = None>>) /\
       (<<FINDMID: alist_find fn (fnsems ms_mid) = None>>)) \/

      (exists md (f: fspecbody),
          (<<STB: stb fn = Some (f: fspec)>>) /\
          (<<FINDSRC: alist_find fn (fnsems ms_mid2) =
                      Some (transl_all (T:=_)
                              (SModSem.mn
                                 (SMod.get_modsem md sk))
                              ∘ fun_to_mid2 (fsb_body f))>>) /\
          (<<FINDMID: alist_find fn (fnsems ms_mid) =
                      Some (transl_all (T:=_)
                              (SModSem.mn
                                 (SMod.get_modsem md sk))
                              ∘ fun_to_mid stb (fsb_body f))>>)).
  Proof.
    hexploit (stb_find_iff_aux fn). i. des.
    { left. esplits; et. }
    { right. esplits; et. }
  Qed.

  Let adequacy_type_aux__APC:
    forall at_most o0 mn
           st_src0 st_tgt0
    ,
      simg (fun (st_src1: p_state * unit) '(st_tgt1, x) => st_tgt1 = st_tgt0)
           (C.myG o0 at_most + C.d)%ord (Ret (st_src0, tt))
           (EventsL.interp_Es p_mid (transl_all mn (interp_hCallE_mid stb (ord_pure o0) (_APC at_most))) st_tgt0)
  .
  Proof.
    ginit.
    { i. eapply cpn6_wcompat; eauto with paco. }
    (* induction *)
    intros ? ?. remember (mk_opair o0 at_most) as fuel. move fuel at top. revert at_most o0 Heqfuel.
    pattern fuel. eapply well_founded_induction. { eapply wf_opair_lt. } clear fuel.
    intros fuel IH. i.

    rewrite unfold_APC. steps.
    destruct x.
    { steps. }
    steps. hexploit (stb_find_iff s). i. des.
    { rewrite NONE. steps. }
    { rewrite FIND. steps. exfalso. eapply x1; et. }
    rewrite STB. steps.
    steps. rewrite FINDMID. unfold fun_to_mid. steps.
    guclo ordC_spec. econs.
    { eapply OrdArith.add_base_l. }
    guclo ordC_spec. econs.
    { eapply C.my_thm2; et. }
    guclo ordC_spec. econs.
    { rewrite OrdArith.add_assoc. refl. }
    rewrite idK_spec at 1.
    guclo bindC_spec. econs.
    { unfold APC. gstep. mred. eapply simg_chooseR; et; [_ord_step|]. i. steps.
      guclo ordC_spec. econs.
      { instantiate (1:=(C.myG x2 x4 + C.d)%ord).
        rewrite <- C.my_thm3; et.
        rewrite <- C.my_thm1; et.
        rewrite OrdArith.add_assoc.
        rewrite OrdArith.add_assoc.
        eapply add_le_le.
        - eapply Ord.lt_le in x5. rewrite <- x5. refl.
        - etrans; [|eapply OrdArith.add_base_l]. etrans; [|eapply OrdArith.add_base_l]. refl.
      }
      eapply IH; auto. econs. left. auto.
    }

    i. ss. destruct vret_tgt as [? []]. destruct vret_src as [? []]. ss. des; subst.
    unfold idK. unfold C.f.
    guclo ordC_spec. econs.
    { rewrite <- OrdArith.add_assoc. refl. }
    steps.
    guclo ordC_spec. econs.
    { eapply OrdArith.add_base_l. }
    { eapply IH; et. econs; et. right; split; et. refl. }
  Qed.

  Let adequacy_type_aux_APC:
    forall o0 st_src0 st_tgt0 mn
    ,
      simg (fun (st_src1: p_state * unit) '(st_tgt1, _) => st_tgt1 = st_tgt0)
           (C.myF o0)%ord (Ret (st_src0, tt))
           (EventsL.interp_Es p_mid (transl_all mn (interp_hCallE_mid stb (ord_pure o0) APC)) st_tgt0)
  .
  Proof.
    ginit.
    { i. eapply cpn6_wcompat; eauto with paco. }
    i. unfold APC.
    guclo ordC_spec. econs.
    { rewrite <- C.my_thm1. refl. }
    unfold C.c.
    guclo ordC_spec. econs.
    { rewrite <- OrdArith.add_assoc. refl. }
    steps.
    guclo ordC_spec. econs.
    { etrans; [|eapply OrdArith.add_base_l]. eapply add_le_le; [|refl].
      instantiate (1:=C.myG o0 x).
      eapply Ord.lt_le in x0. rewrite <- x0. refl. }
    gfinal. right.
    eapply adequacy_type_aux__APC.
  Qed.

  Lemma idK_spec2: forall E A B (a: A) (itr: itree E B), itr = Ret a >>= fun _ => itr. Proof. { i. ired. ss. } Qed.

  Definition formula (o0: ord): Ord.t :=
    match o0 with
    | ord_pure o0 => (10 + C.myF o0)%ord
    | ord_top => 100%ord
    end
  .

  (* Let wf: W -> W -> Prop := eq. *)
  (* Let wf': forall {X}, (W * X)%type -> (W * X)%type -> Prop := eq. *)

  Let adequacy_type_aux:
    forall
      o0
      A (body: itree _ A) st_src0 st_tgt0 mn
      (SIM: st_tgt0 = st_src0)
    ,
      simg eq
           (formula o0 + 50)%ord
           (EventsL.interp_Es p_mid2 (transl_all mn (interp_hCallE_mid2 body)) st_src0)
           (EventsL.interp_Es p_mid (transl_all mn (interp_hCallE_mid stb o0 body)) st_tgt0)
  .
  Proof.
    ginit.
    { i. eapply cpn6_wcompat; eauto with paco. }
    gcofix CIH. i. ides body.
    { steps. }
    { steps. gbase. eapply CIH; ss. }

    destruct e; cycle 1.
    { rewrite <- bind_trigger. resub. steps.
      destruct s; ss.
      { destruct p; resub; ss.
        - steps. gbase. eapply CIH; ss; et.
        - steps. gbase. eapply CIH; ss; et.
      }
      { dependent destruction e; resub; ss.
        - steps_strong. exists x_tgt. steps. gbase. eapply CIH; et.
        - steps_strong. exists x_src. steps. gbase. eapply CIH; et.
        - steps_strong. gbase. eapply CIH; et.
      }
    }
    dependent destruction h.
    rewrite <- bind_trigger. resub.
    ired_both. hexploit (stb_find_iff fn). i. des.
    { rewrite NONE. steps. }
    { rewrite FIND. steps. destruct tbr.
      { exfalso. eapply x; ss. }
      steps. rewrite FINDSRC. steps.
    }
    rewrite STB. steps. destruct tbr.
    (* PURE *)
    { Local Opaque ord_lt.
      ired_both. seal_left.
      gstep. econs; et.
      { _ord_step. }
      i. ired_both. unseal_left. steps.
      rewrite FINDMID. unfold fun_to_mid. ired_both. steps.
      guclo ordC_spec. econs.
      { eapply OrdArith.add_base_l. }
      rewrite idK_spec2 at 1.
      guclo bindC_spec. econs.
      { gfinal. right. eapply paco6_mon. { eapply adequacy_type_aux_APC. } ii; ss. }
      i. steps. steps_strong. exists x2. steps.
      gbase. eapply CIH. ss.
    }

    (* IMPURE *)
    { Local Opaque ord_lt. unfold guarantee.
      ired_both. seal_left.
      gstep. econs; et.
      { _ord_step. }
      i. ired_both. unseal_left. steps.
      rewrite FINDMID. rewrite FINDSRC.
      unfold fun_to_mid2, cfunN, fun_to_mid. steps.
      guclo ordC_spec. econs.
      { eapply OrdArith.add_base_l. }
      guclo bindC_spec. econs.
      { gbase. eapply CIH. ss. }
      i. subst. steps.
      steps.
      gbase. eapply CIH. ss.
    }
  Unshelve.
    all: ss.
    all: try (by exact Ord.O).
    all: try (by exact 0).
  Qed.

  Lemma sk_eq:
    ModL.sk (Mod.add_list mds_mid) = ModL.sk (Mod.add_list mds_mid2).
  Proof.
    unfold ms_mid, ms_mid2, mds_mid2, mds_mid, ModL.enclose.
    rewrite ! Mod.add_list_sk. f_equal.
    generalize mds. clear. i. induction mds; ss.
    rewrite IHl. auto.
  Qed.

  Lemma initial_mrs_eq:
    initial_mrs ms_mid = initial_mrs ms_mid2.
  Proof.
    pose proof sk_eq.
    unfold ms_mid, ms_mid2, mds_mid2, mds_mid, ModL.enclose.
    unfold mds_mid2, mds_mid in H. rewrite H.
    generalize (ModL.sk (Mod.add_list (List.map (SMod.to_mid2 stb) mds))). i.
    rewrite ! Mod.add_list_initial_mrs.
    generalize mds. clear. i. induction mds; auto.
    ss. rewrite IHl. auto.
  Qed.

  Lemma fns_eq:
    (List.map fst (fnsems (ModL.enclose (Mod.add_list mds_mid))))
    =
    (List.map fst (fnsems (ModL.enclose (Mod.add_list mds_mid2)))).
  Proof.
    pose proof sk_eq. unfold ModL.enclose.
    unfold mds_mid2, mds_mid, ModL.enclose.
    unfold mds_mid2, mds_mid in H. rewrite H.
    generalize (ModL.sk (Mod.add_list (List.map (SMod.to_mid2 stb) mds))). i.
    rewrite ! Mod.add_list_fns. rewrite ! List.map_map. f_equal.
    f_equal. extensionality sm. ss. rewrite ! List.map_map. f_equal.
    extensionality fnsb. destruct fnsb as [fn sb]. ss.
  Qed.

  Context `{CONF: EMSConfig}.
  Definition midConf: EMSConfig := {| finalize := finalize; initial_arg := Any.pair ord_top↑ initial_arg |}.
  Theorem adequacy_type_m2m:
    Beh.of_program (@ModL.compile midConf (Mod.add_list mds_mid)) <1=
    Beh.of_program (ModL.compile (Mod.add_list mds_mid2)).
  Proof.
    eapply adequacy_global_itree; ss.
    exists (200)%ord.
    ginit.
    { eapply cpn6_wcompat; eauto with paco. }
    unfold ModSemL.initial_itr, ModSemL.initial_itr. Local Opaque ModSemL.prog. ss.
    unfold ITree.map. steps.
    2: {
      Local Transparent ModSemL.prog.
      unfold ModSemL.prog at 4.
      unfold ModSemL.prog at 2.
      Local Opaque ModSemL.prog.
      ss. steps_strong.
      esplits; et.
      { des. inv x. split.
        { inv H. econs.
          { rewrite fns_eq. auto. }
          { pose proof initial_mrs_eq. unfold ms_mid, ms_mid2 in H.
            rewrite H. auto. }
        }
        { ss. rewrite sk_eq. auto. }
      }
      steps.

      (* stb main *)
      hexploit (stb_find_iff "main"). i. des.
      { unfold ms_mid2 in FINDSRC. rewrite FINDSRC. steps. }
      { unfold ms_mid2 in FINDSRC. rewrite FINDSRC. steps. }

      fold ms_mid2. fold ms_mid.
      rewrite FINDSRC. rewrite FINDMID. steps.
      unfold fun_to_mid2, fun_to_mid, cfunN. steps.

      guclo ordC_spec. econs.
      { eapply OrdArith.add_base_l. }
      guclo bindC_spec. econs.
      { gfinal. right. eapply adequacy_type_aux. ss.
        unfold initial_p_state.
        rewrite initial_mrs_eq. auto. }
      { i. subst. instantiate (1:=10). steps. }
    }
    { instantiate (1:=O).
      ss. repeat (rewrite <- OrdArith.add_from_nat). ss.
      eapply OrdArith.lt_from_nat. lia. }
    Unshelve.
    all: try (by exact Ord.O).
    all: try (by exact 0).
  Qed.

End CANCEL.