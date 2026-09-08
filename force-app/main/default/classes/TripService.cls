/**
 * Logique métier et écritures (DML) relatives à l'objet Trip__c.
 * Construite "inside-out" : les méthodes acceptent des collections de sObjects
 * directement, sans dépendre d'un contexte de trigger, pour rester testables et
 * réutilisables depuis un trigger comme depuis un batch.
 */
public with sharing class TripService {
    /**
     * Crée un Trip__c pour chaque Opportunity venant de passer à Closed Won (GGT-02),
     * en respectant le mapping de champs officiel. Ne plante pas si les champs custom
     * de l'Opportunity sont vides ; un avertissement est journalisé dans ce cas.
     * @param closedWonOpportunities Opportunity venant de passer au stade Closed Won.
     */
    public void createTripsFromOpportunities(List<Opportunity> closedWonOpportunities) {
        List<Trip__c> tripsToInsert = new List<Trip__c>();

        for (Opportunity closedWonOpportunity : closedWonOpportunities) {
            if (hasMissingTripFields(closedWonOpportunity)) {
                System.debug(
                    LoggingLevel.WARN,
                    'Opportunity ' + closedWonOpportunity.Id + ' est passée à Closed Won avec des champs voyage incomplets ; ' +
                    'le Trip__c sera tout de même créé avec les valeurs disponibles.'
                );
            }

            Trip__c trip = new Trip__c();
            trip.Status__c = Constants.TRIP_STATUS_A_VENIR;
            trip.Destination__c = closedWonOpportunity.Destination__c;
            trip.Start_Date__c = closedWonOpportunity.Start_Date__c;
            trip.End_Date__c = closedWonOpportunity.End_Date__c;
            trip.Number_of_Participants__c = closedWonOpportunity.Number_of_Participants__c;
            trip.Total_Cost__c = closedWonOpportunity.Amount;
            trip.Account__c = closedWonOpportunity.AccountId;
            trip.Opportunity__c = closedWonOpportunity.Id;
            tripsToInsert.add(trip);
        }

        insertTrips(tripsToInsert);
    }

    /**
     * Insère des Trip__c de façon bulkifiée, en appliquant le CRUD/FLS de l'utilisateur courant.
     * @param tripsToInsert Trip__c à insérer.
     */
    public void insertTrips(List<Trip__c> tripsToInsert) {
        if (tripsToInsert.isEmpty()) {
            return;
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, tripsToInsert);
        insert decision.getRecords();
    }

    /**
     * Passe les Trip__c fournis au statut "Annulé" (GGT-04) et les met à jour de façon bulkifiée.
     * @param tripsToCancel Trip__c à annuler.
     */
    public void cancelTrips(List<Trip__c> tripsToCancel) {
        if (tripsToCancel.isEmpty()) {
            return;
        }
        for (Trip__c tripToCancel : tripsToCancel) {
            tripToCancel.Status__c = Constants.TRIP_STATUS_ANNULE;
        }
        updateTrips(tripsToCancel);
    }

    /**
     * Met à jour des Trip__c de façon bulkifiée, en appliquant le CRUD/FLS de l'utilisateur courant.
     * @param tripsToUpdate Trip__c déjà modifiés en mémoire, à sauvegarder.
     */
    public void updateTrips(List<Trip__c> tripsToUpdate) {
        if (tripsToUpdate.isEmpty()) {
            return;
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, tripsToUpdate);
        update decision.getRecords();
    }

    /**
     * Calcule le statut attendu d'un Trip__c (GGT-05) selon la position d'aujourd'hui
     * par rapport à ses dates de début et de fin.
     * @param startDate Date de début du Trip__c.
     * @param endDate Date de fin du Trip__c.
     * @return "À venir", "En cours" ou "Terminé" selon la date du jour.
     */
    public String computeStatusForDates(Date startDate, Date endDate) {
        Date today = Date.today();
        if (today < startDate) {
            return Constants.TRIP_STATUS_A_VENIR;
        }
        if (today > endDate) {
            return Constants.TRIP_STATUS_TERMINE;
        }
        return Constants.TRIP_STATUS_EN_COURS;
    }

    private Boolean hasMissingTripFields(Opportunity opp) {
        return opp.Destination__c == null
            || opp.Start_Date__c == null
            || opp.End_Date__c == null
            || opp.Number_of_Participants__c == null;
    }
}
