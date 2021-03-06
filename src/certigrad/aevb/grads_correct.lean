/-
Copyright (c) 2017 Daniel Selsam. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Daniel Selsam

Proofs that integrating out the KL and reparametizing are sound when
applied to the naive variational encoder.
-/
import .util .graph ..prove_model_ok ..backprop_correct

namespace certigrad
namespace aevb

open graph list tactic certigrad.tactic

set_option profiler true

#print "proving backprop_correct_on_aevb..."

theorem backprop_correct_on_aevb (a : arch) (ws : weights a) (x_data : T [a^.n_in, a^.n_x]) :
let g : graph := reparam (integrate_kl $ naive_aevb a x_data) in
let fdict : env := mk_input_dict ws x_data g in
∀ (tgt : reference) (idx : ℕ) (H_at_idx : at_idx g^.targets idx tgt),
∇ (λ θ₀, E (graph.to_dist (λ m, ⟦sum_costs m g^.costs⟧) (env.insert tgt θ₀ fdict) g^.nodes) dvec.head) (env.get tgt fdict)
=
E (graph.to_dist (λ m, backprop g^.costs g^.nodes m g^.targets) fdict g^.nodes) (λ dict, dvec.get tgt.2 dict idx) :=
by prove_model_ok

end aevb
end certigrad
