import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getObjectFields from '@salesforce/apex/HDT_LC_ActivityDetail.getObjectFields';

export default class HdtActivityDetail extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @track show=false;
    @track objectList=[];
    @track activeSections=['Order','Activity','Case','Account']; //>>> marco.arci@webresults.it Aggiunta sezione Account aperta

    //START>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
    caseId;
    orderId;
    //END>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
    accountId; //>>>marco.arci@webresults.it Aggiunta AccountId

    connectedCallback(){
       this.loadContext();
    }

    async loadContext(){
        const result= await getObjectFields({"idActivity":this.recordId});
        this.getObjectList(result);
        this.show=true;
    }

    getObjectList(objectMap){
        try{
            for(var key in objectMap){
                var campi=[];
                var i=0;
                for(var i in objectMap[key].fieldList){
                    //campi.push(objectMap[key].fieldList[i].wrts_prcgvr__Field__c);
                    //START>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
                    if(!['Id', 'id', 'CaseNumber', 'OrderNumber','Name'].includes(objectMap[key].fieldList[i].wrts_prcgvr__Field__c)){ //>>>marco.arci@webresults.it Aggiunta AccountName
                        campi.push({isLink: false, fieldName:objectMap[key].fieldList[i].wrts_prcgvr__Field__c});
                    }
                    //END>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
                }
                if(key=='wrts_prcgvr__Activity__c'){
                    this.objectList.push({api:key, label:'Activity' , fields:campi, id:objectMap[key].objectId});
                }else{
                    //START>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
                    if(key=='Order'){
                        this.orderId = objectMap[key].objectId;
                        campi.push({isLink: true, fieldName:'OrderNumber', fieldValue:objectMap[key].objectName});
                    }
                    if(key=='Case'){
                        this.caseId = objectMap[key].objectId;
                        campi.push({isLink: true, fieldName:'CaseNumber', fieldValue:objectMap[key].objectName});
                    }
                    //END>> costanzo.lomele@webresults.it 18/09/21 - OrderNumber/CaseNumber cliccabile
                    //>>>START marco.arci@webresults.it Aggiunta Account linkabile
                    if(key=='Account'){
                        this.accountId = objectMap[key].objectId;
                        campi.push({isLink: true, fieldName:'Name', fieldValue:objectMap[key].objectName});
                    }
                    //>>>END marco.arci@webresults.it Aggiunta Account linkabile
                    this.objectList.push({api:key, label:key , fields:campi, id:objectMap[key].objectId});
                }
            }
            //START>> costanzo.lomele@webresults.it 18/09/21 - metto per prima la sezione dell'activity
            let activityObj = this.objectList.find(curObj => curObj.api == 'wrts_prcgvr__Activity__c');
            if(activityObj){
                let tempList = this.objectList;
                //let firstObj = tempList[0];
                //tempList.push(firstObj);
                tempList.splice(tempList.indexOf(activityObj), 1);
                tempList.splice(0, 0, activityObj);
                this.objectList = tempList;
            }
            //END>> costanzo.lomele@webresults.it 18/09/21 - metto per prima la sezione dell'activity
        }
        catch(e){
            console.error(e);
        }
    }

    //START>> costanzo.lomele@webresults.it 18/09/21 - metto per prima la sezione dell'activity
    redirectToRecord(event){
        let clickedField = event.currentTarget.getAttribute("data-id");
        this[NavigationMixin.Navigate]({
            'type': 'standard__recordPage',
            'attributes': {
                'recordId': clickedField == 'CaseNumber' ? this.caseId : (clickedField == 'OrderNumber' ? this.orderId : (clickedField == 'Name' ? this.accountId : null)), //>>> marco.arci@webresults.it Aggiunta AccountId
                'objectApiName': clickedField == 'CaseNumber' ? 'Case' : (clickedField == 'OrderNumber' ? 'Order' : (clickedField == 'Name' ? 'Account' : null)), //>>> marco.arci@webresults.it Aggiunta Account 
                'actionName': 'view'
            }
        });
    }
    //END>> costanzo.lomele@webresults.it 18/09/21 - metto per prima la sezione dell'activity
}