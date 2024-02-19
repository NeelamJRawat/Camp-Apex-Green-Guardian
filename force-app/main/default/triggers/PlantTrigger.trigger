trigger PlantTrigger on CAMPX__Plant__c (before insert,after insert,after delete,after update) {
	if(trigger.isbefore){
		// Create a set to hold the IDs of all gardens in "Permanent Closure" status
		Set<Id> closedGardenIds = new Set<Id>();

		// Query for all gardens in "Permanent Closure" status
		for (CAMPX__Garden__c garden : [SELECT Id FROM CAMPX__Garden__c WHERE CAMPX__Status__c = 'Permanent Closure']) {
			closedGardenIds.add(garden.Id);
		}

		for (CAMPX__Plant__c plant : Trigger.new) {
			// Check if the garden associated with the plant is in "Permanent Closure" status
			if (closedGardenIds.contains(plant.CAMPX__Garden__c)) {
				plant.addError('The garden selected for this plant is permanently closed. Please select a different garden.');
			}
		}
		Set <Id> GardenIds = new Set<Id>();
		for(CAMPX__Plant__c Plnt: trigger.new){
			if(Plnt.CAMPX__Soil_Type__c == Null ){
				Plnt.CAMPX__Soil_Type__c = 'All Purpose Potting Soil';
			}
			if(Plnt.CAMPX__Water__c == Null){
				Plnt.CAMPX__Water__c = 'Once Weekly';
			}
			if(Plnt.CAMPX__Sunlight__c == null && Plnt.CAMPX__Garden__c != Null){
				GardenIds.add(Plnt.CAMPX__Garden__c);
			}
		}
		Map<Id,CAMPX__Garden__c> GardenMap = new Map<Id,CAMPX__Garden__c>([Select Id, CAMPX__Sun_Exposure__c from CAMPX__Garden__c where id IN: GardenIds]);
		for(CAMPX__Plant__c Plnt: trigger.new){
			if(Plnt.CAMPX__Sunlight__c == Null ){
				if(Plnt.CAMPX__Garden__c == Null){
					Plnt.CAMPX__Sunlight__c = 'Partial Sun';
				}else if(Plnt.CAMPX__Garden__c != Null && GardenMap.containsKey(Plnt.CAMPX__Garden__c) && GardenMap.get(Plnt.CAMPX__Garden__c).CAMPX__Sun_Exposure__c!=null){
					Plnt.CAMPX__Sunlight__c = GardenMap.get(Plnt.CAMPX__Garden__c).CAMPX__Sun_Exposure__c;
				}

			}
		}
	}
	if(trigger.isafter){

		Set<id> gardenIds = new Set<id>();
		if(Trigger.isDelete ) {
			for(CAMPX__Plant__c plant : Trigger.old) {
				gardenIds.add(plant.CAMPX__Garden__c);
			}

		} else if(Trigger.isInsert  ) {
			for(CAMPX__Plant__c plnt : trigger.new){
				gardenIds.add(plnt.CAMPX__Garden__c);

			}
		}else if(Trigger.isupdate  ) {
			for(CAMPX__Plant__c plnt : trigger.new){
				if((Trigger.oldMap.get(plnt.Id).CAMPX__Garden__c != plnt.CAMPX__Garden__c) || Trigger.oldMap.get(plnt.Id).CAMPX__Status__c != plnt.CAMPX__Status__c) {
					// Add the old Garden Id to the set
					gardenIds.add(Trigger.oldMap.get(plnt.Id).CAMPX__Garden__c);

					gardenIds.add(plnt.CAMPX__Garden__c);

				}
			}
		}
		List<CAMPX__Garden__c> GardenListToUpdate =  [select id,(select id,CAMPX__Status__c from CAMPX__Plants__r) from CAMPX__Garden__c where id in : gardenIds];
		string unhealthyplnt ='Sick Deceased Wilting';
		decimal count = 0;
		for(CAMPX__Garden__c grd:GardenListToUpdate){

			grd.CAMPX__Total_Plant_Count__c = grd.CAMPX__Plants__r.size();
			for(CAMPX__Plant__c plnt: grd.CAMPX__Plants__r){
				if(plnt.CAMPX__Status__c!=null && unhealthyplnt.contains(plnt.CAMPX__Status__c)){
					count++;
				}
			}
			grd.CAMPX__Total_Unhealthy_Plant_Count__c = count;

		}



		update GardenListToUpdate;

	}
}