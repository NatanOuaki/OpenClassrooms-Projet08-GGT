/**
 * Infrastructure : route les Opportunity vers OpportunityTriggerHandler. Ne contient
 * aucune logique métier (GGT-02 est implémenté dans TripService).
 */
trigger OpportunityTrigger on Opportunity (after update) {
    new OpportunityTriggerHandler().afterUpdate(Trigger.new, Trigger.oldMap);
}
