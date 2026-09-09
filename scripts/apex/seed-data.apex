// Seed data GlobalGroupTravel-CRM : jeu de données réaliste couvrant tous les scénarios
// des règles métier GGT-01 à GGT-05. Bulkifié (un DML par type de sObject).
// À exécuter avec : sf apex run --file scripts/apex/seed-data.apex --target-org OC_Projet08

// ---------- 1. Accounts (5) ----------
List<Account> accounts = new List<Account>{
    new Account(Name = 'École Notre-Dame'),
    new Account(Name = 'Association Sportive Étoile'),
    new Account(Name = 'Entreprise TechCorp'),
    new Account(Name = 'Lycée Voltaire'),
    new Account(Name = 'Club Randonnée Nature')
};
insert accounts;

Account ecoleNotreDame = accounts[0];
Account assoEtoile = accounts[1];
Account techCorp = accounts[2];
Account lyceeVoltaire = accounts[3];
Account clubRandonnee = accounts[4];

// ---------- 2. Opportunities (8), dont 2 basculeront en Closed Won ----------
List<Opportunity> opportunities = new List<Opportunity>{
    new Opportunity(
        Name = 'Voyage scolaire Rome',
        AccountId = ecoleNotreDame.Id,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(10),
        Amount = 15000,
        Destination__c = 'Rome',
        Start_Date__c = Date.today().addDays(45),
        End_Date__c = Date.today().addDays(50),
        Number_of_Participants__c = 30
    ),
    new Opportunity(
        Name = 'Séjour linguistique Londres',
        AccountId = ecoleNotreDame.Id,
        StageName = 'Qualification',
        CloseDate = Date.today().addDays(20),
        Amount = 9000,
        Destination__c = 'Londres',
        Start_Date__c = Date.today().addDays(60),
        End_Date__c = Date.today().addDays(65),
        Number_of_Participants__c = 18
    ),
    new Opportunity(
        Name = 'Tournoi sportif Barcelone',
        AccountId = assoEtoile.Id,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(5),
        Amount = 12000,
        Destination__c = 'Barcelone',
        Start_Date__c = Date.today().addDays(40),
        End_Date__c = Date.today().addDays(44),
        Number_of_Participants__c = 22
    ),
    new Opportunity(
        Name = 'Stage sportif Alpes',
        AccountId = assoEtoile.Id,
        StageName = 'Proposal/Price Quote',
        CloseDate = Date.today().addDays(30),
        Amount = 7000,
        Destination__c = 'Chamonix',
        Start_Date__c = Date.today().addDays(70),
        End_Date__c = Date.today().addDays(75),
        Number_of_Participants__c = 15
    ),
    new Opportunity(
        Name = 'Séminaire entreprise Lisbonne',
        AccountId = techCorp.Id,
        StageName = 'Negotiation/Review',
        CloseDate = Date.today().addDays(15),
        Amount = 25000,
        Destination__c = 'Lisbonne',
        Start_Date__c = Date.today().addDays(50),
        End_Date__c = Date.today().addDays(53),
        Number_of_Participants__c = 40
    ),
    new Opportunity(
        Name = 'Team building Amsterdam',
        AccountId = techCorp.Id,
        StageName = 'Closed Lost',
        CloseDate = Date.today().addDays(-5),
        Amount = 6000,
        Destination__c = 'Amsterdam',
        Start_Date__c = Date.today().addDays(20),
        End_Date__c = Date.today().addDays(22),
        Number_of_Participants__c = 12
    ),
    new Opportunity(
        Name = 'Voyage scolaire Berlin',
        AccountId = lyceeVoltaire.Id,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(25),
        Amount = 14000,
        Destination__c = 'Berlin',
        Start_Date__c = Date.today().addDays(55),
        End_Date__c = Date.today().addDays(60),
        Number_of_Participants__c = 28
    ),
    new Opportunity(
        Name = 'Randonnée Pyrénées',
        AccountId = clubRandonnee.Id,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(12),
        Amount = 5000,
        Destination__c = 'Pyrénées',
        Start_Date__c = Date.today().addDays(35),
        End_Date__c = Date.today().addDays(38),
        Number_of_Participants__c = 10
    )
};
insert opportunities;

// Bascule de 2 Opportunity en Closed Won : déclenche OpportunityTrigger -> TripService (GGT-02).
Opportunity voyageRome = opportunities[0];
Opportunity tournoiBarcelone = opportunities[2];
voyageRome.StageName = 'Closed Won';
tournoiBarcelone.StageName = 'Closed Won';
update new List<Opportunity>{ voyageRome, tournoiBarcelone };

// ---------- 3. Contracts (5) ----------
List<Contract> contracts = new List<Contract>{
    new Contract(AccountId = ecoleNotreDame.Id, StartDate = Date.today().addDays(-30), ContractTerm = 12),
    new Contract(AccountId = assoEtoile.Id, StartDate = Date.today().addDays(-60), ContractTerm = 24),
    new Contract(AccountId = techCorp.Id, StartDate = Date.today().addDays(-10), ContractTerm = 12),
    new Contract(AccountId = lyceeVoltaire.Id, StartDate = Date.today().addDays(-90), ContractTerm = 36),
    new Contract(AccountId = clubRandonnee.Id, StartDate = Date.today(), ContractTerm = 12)
};
insert contracts;

// ---------- 4. Trip__c créés manuellement (8), hors du trigger GGT-02 ----------
List<Trip__c> manualTrips = new List<Trip__c>{
    // GGT-04 : à J+7, moins de 10 participants -> sera annulé par TripAutoCancelBatch.
    new Trip__c(
        Account__c = ecoleNotreDame.Id,
        Destination__c = 'Dublin',
        Start_Date__c = Date.today().addDays(7),
        End_Date__c = Date.today().addDays(12),
        Number_of_Participants__c = 5
    ),
    // GGT-04 : à J+7, 15 participants -> ne doit pas être annulé.
    new Trip__c(
        Account__c = assoEtoile.Id,
        Destination__c = 'Porto',
        Start_Date__c = Date.today().addDays(7),
        End_Date__c = Date.today().addDays(13),
        Number_of_Participants__c = 15
    ),
    // GGT-05 : dates entièrement passées -> statut recalculé à "Terminé".
    new Trip__c(
        Account__c = techCorp.Id,
        Destination__c = 'Vienne',
        Start_Date__c = Date.today().addDays(-60),
        End_Date__c = Date.today().addDays(-50)
    ),
    // GGT-05 : dates à cheval sur aujourd'hui -> statut recalculé à "En cours".
    new Trip__c(
        Account__c = lyceeVoltaire.Id,
        Destination__c = 'Athènes',
        Start_Date__c = Date.today().addDays(-3),
        End_Date__c = Date.today().addDays(3)
    ),
    // Déjà "Annulé" avec des dates qui donneraient "Terminé" si le batch GGT-05 le retraitait à tort.
    new Trip__c(
        Account__c = clubRandonnee.Id,
        Destination__c = 'Marrakech',
        Start_Date__c = Date.today().addDays(-40),
        End_Date__c = Date.today().addDays(-30),
        Status__c = 'Annulé'
    ),
    // Voyage futur lointain, participants suffisants -> reste "À venir".
    new Trip__c(
        Account__c = ecoleNotreDame.Id,
        Destination__c = 'Tokyo',
        Start_Date__c = Date.today().addDays(90),
        End_Date__c = Date.today().addDays(97),
        Number_of_Participants__c = 20
    ),
    // GGT-04 : à J+7 mais participants non renseignés -> ne doit pas être annulé (exclusion explicite des valeurs vides).
    new Trip__c(
        Account__c = assoEtoile.Id,
        Destination__c = 'Séville',
        Start_Date__c = Date.today().addDays(7),
        End_Date__c = Date.today().addDays(11)
    ),
    // Réservation manuelle sans Opportunity liée (Opportunity__c optionnel).
    new Trip__c(
        Account__c = techCorp.Id,
        Destination__c = 'Prague',
        Start_Date__c = Date.today().addDays(30),
        End_Date__c = Date.today().addDays(35),
        Number_of_Participants__c = 25
    )
};
insert manualTrips;

// ---------- 5. Tasks (10), réparties sur Account/Opportunity/Trip__c ----------
List<Task> tasks = new List<Task>{
    new Task(WhatId = ecoleNotreDame.Id, Subject = 'Appeler le référent voyage scolaire', ActivityDate = Date.today().addDays(2), Status = 'Not Started'),
    new Task(WhatId = ecoleNotreDame.Id, Subject = 'Envoyer devis Rome', ActivityDate = Date.today().addDays(1), Status = 'Completed'),
    new Task(WhatId = assoEtoile.Id, Subject = 'Confirmer les dates du tournoi', ActivityDate = Date.today().addDays(3), Status = 'Not Started'),
    new Task(WhatId = techCorp.Id, Subject = 'Préparer proposition séminaire', ActivityDate = Date.today().addDays(4), Status = 'In Progress'),
    new Task(WhatId = lyceeVoltaire.Id, Subject = 'Relancer le lycée pour Berlin', ActivityDate = Date.today().addDays(5), Status = 'Not Started'),
    new Task(WhatId = clubRandonnee.Id, Subject = 'Valider itinéraire Pyrénées', ActivityDate = Date.today().addDays(6), Status = 'Not Started'),
    new Task(WhatId = voyageRome.Id, Subject = 'Signer le bon de commande Rome', ActivityDate = Date.today(), Status = 'Completed'),
    new Task(WhatId = tournoiBarcelone.Id, Subject = 'Vérifier le paiement acompte Barcelone', ActivityDate = Date.today().addDays(1), Status = 'In Progress'),
    new Task(WhatId = manualTrips[0].Id, Subject = 'Relancer participants Dublin (sous le seuil)', ActivityDate = Date.today(), Status = 'Not Started'),
    new Task(WhatId = manualTrips[3].Id, Subject = 'Suivi voyage en cours Athènes', ActivityDate = Date.today(), Status = 'In Progress')
};
insert tasks;

System.debug(LoggingLevel.INFO, 'Seed data GlobalGroupTravel-CRM terminé : ' +
    accounts.size() + ' Account, ' +
    opportunities.size() + ' Opportunity, ' +
    contracts.size() + ' Contract, ' +
    manualTrips.size() + ' Trip__c manuels, ' +
    tasks.size() + ' Task.');
