/**
 * Encapsule tout l'accès en lecture (SOQL) à l'objet Account.
 */
public with sharing class AccountSelector {
    /**
     * Retourne les Account correspondant aux Ids fournis.
     * @param accountIds Ids d'Account à charger.
     * @return Liste des Account accessibles à l'utilisateur courant.
     */
    public List<Account> selectByIds(Set<Id> accountIds) {
        List<Account> accounts = [
            SELECT Id, Name, OwnerId
            FROM Account
            WHERE Id IN :accountIds
        ];
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, accounts);
        return decision.getRecords();
    }
}
