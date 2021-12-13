import { LightningElement, api, track,wire } from 'lwc';
import getActivity from '@salesforce/apex/HDT_LC_AppointmentAgenda.getActivity';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

const NEW_DATE_VALID_STATE = ['Creata'];
const DELETE_DATE_VALID_STATE = ['Presa appuntamento in corso'];
const EDIT_DATE_VALID_STATE = ['Appuntamento confermato','Modifica confermata'];
const RESUME_DATE_VALID_STATE = ['Presa appuntamento in corso'];
const OBJECT_FIELDS =[
    'MaxTimeModificationAppointment__c',
    'MaxDateModificationAppointment__c',
    'wrts_prcgvr__Status__c',
    'AppointmentCompetence__c',
    'isAtoA__c'
    
];


export default class HdtAppointmentHandler extends LightningElement{
    showAgenda = false;
    hasRendered = false;
    isCommunity = false;
    @api recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('@@@@currentpagereference',JSON.stringify(currentPageReference));
        if (currentPageReference && currentPageReference.state.c__activityId) {
            console.log('@@@@gestione Community');
            this.recordId = currentPageReference.state.c__activityId;
            this.isCommunity = true;
        }
    }


    @track tempList = [
        {label: 'Prendi Appuntamento ', name: 'newDate', iconName: 'utility:retail_execution', desc: 'Prendi un nuovo appuntamento con il DL', enable : false},
        {label: 'Modifica Appuntamento', name: 'editDate', iconName: 'utility:record_delete', desc: 'Modifica un appuntamento Confermato', enable : false},
        {label: 'Annulla Appuntamento', name: 'deleteDate', iconName: 'utility:delete', desc: 'Annulla un appuntamento non ancora Confermato', enable : false},
        {label: 'Riprendi Appuntamento', name: 'resumeDate', iconName: 'utility:record_delete', desc: 'Riprendi un appuntamento non confermato', enable : false}
    ];
    @track params={};
    get stmtValue(){
        return this.tempList;
    }

    @wire(getActivity,{activityId : '$recordId', fields: OBJECT_FIELDS })
    wiredActivity(value){
        this.wiredActivity = value;
        const { data, error } = value; 
        console.log('@@@@wiredActivity ', this.recordId);
        console.log('@@@@wiredActivity ', JSON.stringify(data));
        console.log('@@@@wiredActivity ', JSON.stringify(error));
        if (data){
            this.activity = JSON.parse(data);
            this.tempList.forEach( item =>{
                let itemName = item.name;
                let enable = false;
                let stato = this.activity.wrts_prcgvr__Status__c;
                if (this.activity.AppointmentCompetence__c != 'Distributore' && this.activity.isAtoA__c){
                    switch (itemName){
                        case 'newDate':
                            if (NEW_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                        case 'editDate':
                            let maxDayInMs = this.getMaxDateInMilliseconds(this.activity.MaxDateModificationAppointment__c,this.activity.MaxTimeModificationAppointment__c); 
                            let nowInMs = Date.now();
                            console.log('@@@@maxDayInMs: ' + maxDayInMs);
                            console.log('@@@@nowInMs: ' + nowInMs);
                            if (EDIT_DATE_VALID_STATE.indexOf(stato) != -1 && maxDayInMs != -1 && nowInMs < maxDayInMs){
                                enable = true;
                            }
                        break;
                        case 'deleteDate':
                            if (DELETE_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                        case 'resumeDate':
                            if (RESUME_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                    }
                } 
                item.enable = enable; 
            });
            this.showAgenda = false;
        }else if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
    }
    
    clickOperation(event){
        switch (event.currentTarget.name){
            case 'newDate':
                this.params ={
                    method : 'handleSearch',
                    searchType : 'FirstSearch'
                };
            break;
            case 'editDate':
                this.params ={
                    method : 'handleSearch',
                    searchType : 'NewSlotModify'
                };
            break;
            case 'deleteDate':
                this.params ={
                    method : 'handleCancellation'
                };
            break;
            case 'resumeDate':
                this.params ={ 
                    method : 'handleSearch',
                    searchType : 'NewSlot'
                };
            break;
        }
        this.params = {...this.params,userCommunity : this.isCommunity};
        this.showAgenda = true;
    }

    cancelEvent(event){
        this.params = {};
        console.log('@@@@this.org ' + event.detail);
        if(event.detail === true){
            if (this.isCommunity){
                let myWiredActivity = this.wiredActivity;
                setTimeout(function(){refreshApex(myWiredActivity)},5000);
            }else{
                refreshApex(this.wiredActivity);
            }
        }else{
            this.showAgenda = false;
        }
        
    }

    

    

    //return date + time in ms
    getMaxDateInMilliseconds(dateToWork,timeToWork){
        console.log('@@@@dateToWork/timeToWork ' +dateToWork + '/'+ timeToWork);
        let dateToFormat = dateToWork+' '+this.formatTime(timeToWork);
        console.log('@@@@dateToFormat ' +dateToFormat);
        try{
            let d = new Date(dateToFormat);
            return d.getTime();
        }catch(e){
            console.error(e);
            return -1;
        }
    }

    //formate time in 00:00:00:000
    formatTime(timeToFormat){
        if (timeToFormat){
            console.log(timeToFormat);
            let timeInArray = timeToFormat.replace(' ','').split(':');
            console.log('@@@@timeInArray ' +JSON.stringify(timeInArray));
            let formattedDate = '';
            timeInArray.forEach((item,index) => {
                console.log('@@@@item ' + item);
                if (index < 3){
                    item = (item.lenght === 1) ? '0'+item : item;
                    formattedDate += item + ':';
                }
            });
            console.log('@@@@formattedDate ' +formattedDate);
            if (timeInArray.length == 3){
                return formattedDate.substring(0,formattedDate.length - 1);
            }else if (timeInArray.length == 2){
                return formattedDate + '00';
            }
        }
        return -1;
    }
}