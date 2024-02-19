global with sharing class GardenHandler {
global static void calculateCapacity(List<CAMPX__Garden__c> newGardenlist) {
	for(CAMPX__Garden__c grd: newGardenlist){
		decimal capacity = 0;
		if((grd.CAMPX__Max_Plant_Count__c!=0 && grd.CAMPX__Max_Plant_Count__c!=null) && (grd.CAMPX__Total_Plant_Count__c!=0 && grd.CAMPX__Total_Plant_Count__c!=null)){
			capacity = (grd.CAMPX__Total_Plant_Count__c / grd.CAMPX__Max_Plant_Count__c)*100;
		}

		grd.CAMPX__Capacity__c = capacity;
	}
}

global static void calculateHealtIndex(List<CAMPX__Garden__c> newGardenlist){
	for(CAMPX__Garden__c grd: newGardenlist){

		if(grd.CAMPX__Total_Plant_Count__c!=0 && grd.CAMPX__Total_Plant_Count__c!=null){
			grd.CAMPX__Health_Index__c = ((grd.CAMPX__Total_Plant_Count__c-grd.CAMPX__Total_Unhealthy_Plant_Count__c)/grd.CAMPX__Total_Plant_Count__c)*100;
		}
	}

}
global static void setStatus(List<CAMPX__Garden__c> newGardenlist){
	for(CAMPX__Garden__c grd: newGardenlist){
		if(!grd.CAMPX__Status__c.contains('Permanent Closure')){
			if(grd.CAMPX__Capacity__c==0){
				grd.CAMPX__Status__c = 'Awaiting Resources';
			}else if(grd.CAMPX__Capacity__c>100)
			{
				grd.CAMPX__Status__c = 'Over Capacity';
			}else if(grd.CAMPX__Capacity__c>=70 && grd.CAMPX__Capacity__c<=100 && grd.CAMPX__Total_Plant_Count__c>=grd.CAMPX__Minimum_Plant_Count__c && grd.CAMPX__Health_Index__c>=70){
				grd.CAMPX__Status__c ='Operational';
			}else if(grd.CAMPX__Capacity__c<70 && grd.CAMPX__Capacity__c>0 || grd.CAMPX__Total_Plant_Count__c>grd.CAMPX__Minimum_Plant_Count__c || grd.CAMPX__Health_Index__c<70)
			{
				grd.CAMPX__Status__c ='Awaiting Resources';

			}
		}
	}

}
global static void validatePlantCount(List<CAMPX__Garden__c> newGardenlist){
	for(CAMPX__Garden__c grd: newGardenlist){

		if(grd.CAMPX__Total_Plant_Count__c<0 || grd.CAMPX__Max_Plant_Count__c<0 || grd.CAMPX__Minimum_Plant_Count__c<0 || grd.CAMPX__Total_Unhealthy_Plant_Count__c<0){
			grd.addError('Plant Count fields must be greater than or equal to zero.');
		}
		if(grd.CAMPX__Total_Plant_Count__c>0 && (grd.CAMPX__Max_Plant_Count__c==null || grd.CAMPX__Minimum_Plant_Count__c==null)){
			grd.addError('Maximum and Minimum Plant Count fields cannot be blank when there are plants in the Garden.');
		}
		if(grd.CAMPX__Max_Plant_Count__c!=0 &&grd.CAMPX__Max_Plant_Count__c!=null && grd.CAMPX__Minimum_Plant_Count__c!=null && grd.CAMPX__Minimum_Plant_Count__c!=null && grd.CAMPX__Max_Plant_Count__c<grd.CAMPX__Minimum_Plant_Count__c){
			grd.addError('The Maximum Plant Count must be greater than or equal to the Minimum Plant Count');
		}
	}

}
}