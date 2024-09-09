--*** DEPRECATED ***
--use ChaseAndAttackAndAvoid instead
--this is kept around for mod backward compatibiliy

require("behaviours/chaseandattackandavoid")

StalkerChaseAndAttack = Class(ChaseAndAttackAndAvoid, function(self, inst, findavoidanceobjectfn, max_chase_time, give_up_dist, max_attacks, findnewtargetfn, walk)
    --avoid_dist: 6  <--  (stargate radius + stalker radius + some breathing room)
    ChaseAndAttackAndAvoid._ctor(self, inst, findavoidanceobjectfn, 6, max_chase_time, give_up_dist, max_attacks, findnewtargetfn, walk)
end)
