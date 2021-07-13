Require Import HoareDef OpenDef2 STB Repeat0 Repeat1 SimModSemdouble.
Require Import Coqlib.
Require Import ImpPrelude.
Require Import Skeleton.
Require Import PCM.
Require Import ModSem Behavior.
Require Import Relation_Definitions.

(*** TODO: export these in Coqlib or Universe ***)
Require Import Relation_Operators.
Require Import RelationPairs.
From ITree Require Import
     Events.MapDefault.
From ExtLib Require Import
     Core.RelDec
     Structures.Maps
     Data.Map.FMapAList.

Require Import HTacticsdouble ProofMode Invariant.

Require Import Imp.
Require Import ImpNotations.
Require Import ImpProofs2.

Set Implicit Arguments.

Local Open Scope nat_scope.





Section SIMMODSEM.

  Context `{Σ: GRA.t}.

  Let W: Type := Any.t * Any.t.

  Variable FunStb: Sk.t -> gname -> option fspec.
  Variable GlobalStb: Sk.t -> gname -> option fspec.

  Let wf: _ -> W -> Prop :=
    @mk_wf
      _
      unit
      (fun _ _ _ => True%I)
  .

  Hypothesis FunStb_incl: forall sk,
      stb_incl (FunStb sk) (GlobalStb sk).

  Hypothesis GlobalStb_repeat: forall sk,
      fn_has_spec (GlobalStb sk) "repeat" (Repeat1.repeat_spec FunStb sk).

  Hypothesis GlobalStb_complete: forall sk fn,
      GlobalStb sk fn <> None.

  Ltac check_o :=
    match goal with
    | [ |- (gpaco8 _ _ _ _ _ _ _ ?o_src ?o_tgt _ _ _) ] =>
      pose o_src; pose o_tgt
    end.

  Lemma foo (n: nat) (o: Ord.t)
    :
      (n < o + (S n))%ord.
  Proof.
  Admitted.

  Lemma goo (n: nat) (o: Ord.t)
    :
      (o < o + (S n))%ord.
  Proof.
  Admitted.

  Hint Resolve goo: ord_step.

  Theorem correct: refines2 [Repeat0.Repeat] [Repeat1.Repeat FunStb GlobalStb].
  Proof.
    eapply adequacy_local2. econs; ss.
    i. econstructor 1 with (wf:=wf) (le:=top2); ss.
    2: { esplits; et. red. econs. eapply to_semantic. et. }
    econs; ss. unfold repeatF. kinit.
    { harg. destruct x as [[[f n] x] f_spec]. ss. mDesAll. des; clarify.
      steps. force_r; auto. check_o. des_ifs.
      { astart 0. astop. steps. force_l. eexists. steps.

  eapply (@hret_clo _ _ _); unshelve_goal.
  destruct true.

  oauto.

  [oauto
  |eassumption
  |
  |start_ipm_proof
  |try by (i; (try unfold lift_rel); esplits; et)
  ].


        hret _; ss.
        iPureIntro. splits; et. destruct n; et. exfalso. lia.
      }
      { check_o. destruct n.
        { exfalso. lia. }
        steps. inv PURE4. inv SPEC. rewrite FBLOCK. unfold ccallU. steps.
        astart 2. check_o. acatch.
        {

          Hint Rewrite <- OrdArith.add_from_nat: ord_step.

          match goal with
          | P

          autorewrite with ord_step.

 Set Printing All. simpl. rewrite <- ! OrdArith.add_from_nat. oauto.


        { eapply FunStb_incl. et. }
        hcall_weaken _ _ _ _ with ""; et.
        { splits; ss. eapply Ord.le_lt_lt.
          { eapply OrdArith.add_base_l. }
          { eapply OrdArith.lt_add_r. rewrite Ord.from_nat_S. eapply Ord.S_lt. }
        }
        ss. mDesAll. des; clarify.
        hexploit GlobalStb_repeat. i. inv H. steps. acatch.
        { et. }
        hcall_weaken (Repeat1.repeat_spec FunStb sk) _ (_, n, _, _) _ with ""; ss.
        { iPureIntro. esplits; et.
          { repeat f_equal. lia. }
          { unfold_intrange_64. unfold sumbool_to_bool in *. des_ifs; try lia. }
          { econs; et. econs; et. }
        }
        { splits; ss. eauto with ord_step. }
        mDesAll. des; clarify. steps.
        astop. steps. force_l. eexists. steps.
        hret _; ss.
      }
    }
    { harg. mDesAll. des; clarify. steps. }
    Unshelve. all: ss.
  Qed.
        eapply (@hret_clo _ _ _ _).

; unshelve_goal.

hret _
        eapply goo.

        oauto. oauto.



 force_l. eexists. steps.

        Create HintDb ord_step2.
        Hint Resolve foo: ord_step2.
        eapply (@hret_clo _ _ _ _); unshelve_goal.
        { Set Printing All. eapply foo.


        Hint Resolve foo ord_from_lt_sub OrdArith.lt_add_r Nat.lt_succ_diag_r (* OrdArith.lt_from_nat *): ord_step2.
        Hint Extern 1000 => lia: ord_step2.
        Ltac oauto2 :=
          try by (simpl; let bar := fresh in place_bar bar; clear_until bar; eauto with ord_step2).

        eapply (@hret_clo _ _ _ _); unshelve_goal.

        oauto2.

oauto.
        eapply OrdArith.add_base_l

  eapply OrdArith.add_from_lt.
  oauto.

  [oauto
  |eassumption
  |
  |start_ipm_proof
  |try by (i; (try unfold lift_rel); esplits; et)
  ].


        hret _; ss.
        iPureIntro. splits; et. destruct n; et. exfalso. lia.
      }
      { check_o. destruct n.
        { exfalso. lia. }
        steps. inv PURE4. inv SPEC. rewrite FBLOCK. unfold ccallU. steps.
        check_o.

 simpl in t0. Set Printing All.
        astart 2. acatch.
        { eapply FunStb_incl. et. }
        hcall_weaken _ _ _ _ with ""; et.
        { splits; ss. eapply Ord.le_lt_lt.
          { eapply OrdArith.add_base_l. }
          { eapply OrdArith.lt_add_r. rewrite Ord.from_nat_S. eapply Ord.S_lt. }
        }
        ss. mDesAll. des; clarify.
        hexploit GlobalStb_repeat. i. inv H. steps. acatch.
        { et. }
        hcall_weaken (Repeat1.repeat_spec FunStb sk) _ (_, n, _, _) _ with ""; ss.
        { iPureIntro. esplits; et.
          { repeat f_equal. lia. }
          { unfold_intrange_64. unfold sumbool_to_bool in *. des_ifs; try lia. }
          { econs; et. econs; et. }
        }
        { splits; ss. eauto with ord_step. }
        mDesAll. des; clarify. steps.
        astop. steps. force_l. eexists. steps.
        hret _; ss.
      }
    }
    { harg. mDesAll. des; clarify. steps. }
    Unshelve. all: ss.
  Qed.

End SIMMODSEM.
