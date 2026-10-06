/**
 * Infrastructure : se déclenche sur tous les événements Trip__c et délègue
 * uniquement à TripTriggerHandler.dispatch(). Aucune logique ni appel métier ici.
 */
trigger TripTrigger on Trip__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    new TripTriggerHandler().dispatch();
}
