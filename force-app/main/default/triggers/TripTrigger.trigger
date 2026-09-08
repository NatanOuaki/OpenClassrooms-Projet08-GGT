/**
 * Infrastructure : route les Trip__c vers TripTriggerHandler. Ne contient aucune
 * logique métier (GGT-03 est implémenté dans TripTriggerHandler).
 */
trigger TripTrigger on Trip__c (before insert, before update) {
    new TripTriggerHandler().validateDateConsistency(Trigger.new);
}
