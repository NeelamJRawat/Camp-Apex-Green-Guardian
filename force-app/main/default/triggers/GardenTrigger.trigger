trigger GardenTrigger on CAMPX__Garden__c (before insert,before update, after insert,after update) {

	if(Trigger.isbefore){
		GardenHandler.validatePlantCount(trigger.new);
		AssignTask.setStartDate(trigger.new);
		
		GardenHandler.calculateCapacity(trigger.new);
		GardenHandler.calculateHealtIndex(trigger.new);
		GardenHandler.setStatus(trigger.new);

	}
	if(Trigger.isInsert){
		AssignTask.assignTask(trigger.new);
	}else if (Trigger.isUpdate){
		AssignTask.reassignTask(trigger.new,trigger.old);
	}




}