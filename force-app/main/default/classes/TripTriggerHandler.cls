/**
 * Infrastructure de routage pour TripTrigger : porte la règle de cohérence des dates (GGT-03).
 */
public with sharing class TripTriggerHandler {
    /**
     * Bloque tout Trip__c dont la date de fin est antérieure à la date de début.
     * Ne fait rien si l'une des deux dates est vide (GGT-03 ne s'applique qu'aux
     * Trip__c dont les deux dates sont renseignées).
     * @param trips Trigger.new pour un before insert/before update sur Trip__c.
     */
    public void validateDateConsistency(List<Trip__c> trips) {
        for (Trip__c trip : trips) {
            Boolean bothDatesFilled = trip.Start_Date__c != null && trip.End_Date__c != null;
            if (bothDatesFilled && trip.End_Date__c < trip.Start_Date__c) {
                trip.End_Date__c.addError('La date de fin doit être postérieure à la date de début.');
            }
        }
    }
}
