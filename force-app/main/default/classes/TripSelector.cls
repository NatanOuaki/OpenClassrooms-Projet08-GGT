/**
 * Encapsule tout l'accès en lecture (SOQL) à l'objet Trip__c.
 */
public with sharing class TripSelector {
    /**
     * Retourne les Trip__c correspondant aux Ids fournis.
     * @param tripIds Ids de Trip__c à charger.
     * @return Liste des Trip__c accessibles à l'utilisateur courant.
     */
    public List<Trip__c> selectByIds(Set<Id> tripIds) {
        List<Trip__c> trips = [
            SELECT Id, Status__c, Start_Date__c, End_Date__c, Number_of_Participants__c, Destination__c, Total_Cost__c, Account__c, Opportunity__c
            FROM Trip__c
            WHERE Id IN :tripIds
        ];
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, trips);
        return decision.getRecords();
    }

    /**
     * Retourne les Trip__c partant à une date donnée, avec un nombre de participants
     * renseigné et strictement inférieur au seuil fourni, hors Trip__c déjà annulés (GGT-04).
     * @param departureDate Date de départ ciblée (Start_Date__c).
     * @param minParticipants Seuil minimum de participants (exclusif).
     * @return Liste des Trip__c candidats à l'auto-annulation.
     */
    public List<Trip__c> selectDepartingOnDateBelowMinParticipants(Date departureDate, Decimal minParticipants) {
        List<Trip__c> trips = [
            SELECT Id, Status__c, Number_of_Participants__c
            FROM Trip__c
            WHERE Start_Date__c = :departureDate
            AND Number_of_Participants__c != null
            AND Number_of_Participants__c < :minParticipants
            AND Status__c != :Constants.TRIP_STATUS_ANNULE
        ];
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, trips);
        return decision.getRecords();
    }

    /**
     * Retourne uniquement les Trip__c non annulés dont le statut actuel ne correspond
     * plus à leurs dates (GGT-05) : un voyage futur qui n'est pas "À venir", un voyage
     * passé qui n'est pas "Terminé", ou un voyage en cours qui n'est pas "En cours".
     * Les Trip__c déjà "Annulé" sont exclus et ne sont jamais réécrits.
     * @return Liste des Trip__c dont le statut doit être mis à jour.
     */
    public List<Trip__c> selectWithOutdatedStatus() {
        List<Trip__c> trips = [
            SELECT Id, Status__c, Start_Date__c, End_Date__c
            FROM Trip__c
            WHERE Status__c != :Constants.TRIP_STATUS_ANNULE
            AND (
                (Start_Date__c > TODAY AND Status__c != :Constants.TRIP_STATUS_A_VENIR)
                OR (End_Date__c < TODAY AND Status__c != :Constants.TRIP_STATUS_TERMINE)
                OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Status__c != :Constants.TRIP_STATUS_EN_COURS)
            )
        ];
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, trips);
        return decision.getRecords();
    }
}
