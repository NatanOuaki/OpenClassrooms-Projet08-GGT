/**
 * Encapsule l'accès en lecture au Custom Metadata Type Trip_Settings__mdt.
 */
public with sharing class TripSettingsSelector {
    /**
     * Retourne l'enregistrement de paramétrage par défaut utilisé par GGT-04
     * (seuil de participants et fenêtre de jours avant départ).
     * @return L'enregistrement Trip_Settings__mdt.Default.
     */
    public Trip_Settings__mdt selectDefault() {
        return [
            SELECT Min_Participants__c, Days_Before_Departure__c
            FROM Trip_Settings__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
    }
}
