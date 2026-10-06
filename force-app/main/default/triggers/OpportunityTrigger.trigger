/**
 * Infrastructure : se déclenche sur tous les événements Opportunity et délègue
 * uniquement à OpportunityTriggerHandler.dispatch(). Aucune logique ni appel métier ici.
 */
trigger OpportunityTrigger on Opportunity (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    new OpportunityTriggerHandler().dispatch();
}
