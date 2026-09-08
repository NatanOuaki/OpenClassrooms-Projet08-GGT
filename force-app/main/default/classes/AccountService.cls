/**
 * Logique métier et écritures (DML) relatives à l'objet Account.
 */
public with sharing class AccountService {
    /**
     * Crée des Account de façon bulkifiée, en appliquant le CRUD/FLS de l'utilisateur courant.
     * @param accountsToCreate Account à insérer.
     */
    public void createAccounts(List<Account> accountsToCreate) {
        if (accountsToCreate.isEmpty()) {
            return;
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, accountsToCreate);
        insert decision.getRecords();
    }
}
