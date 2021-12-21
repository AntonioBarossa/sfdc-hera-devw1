import { LightningElement, api, track,wire } from 'lwc';
import getActivity from '@salesforce/apex/HDT_LC_AppointmentAgenda.getActivity';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

const NEW_DATE_VALID_STATE = ['Creata','Invio app.to SELF cliente'];
const SELF_DATE_VALID_STATE = ['Creata'];
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
    showForm = false;
    hasRendered = false;
    @api isCommunity = false;
    /* isCommunity = false; */
    @api recordId;

    /* @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state.c__activityId) {
            this.recordId = currentPageReference.state.c__activityId;
            this.isCommunity = true;
        }
    } */


    @track tempList = [
        {label: 'Prendi Appuntamento ', name: 'newDate', iconName: 'utility:retail_execution', desc: 'Prendi un nuovo appuntamento con il DL', enable : false, visible : false},
        {label: 'Modifica Appuntamento', name: 'editDate', iconName: 'utility:record_delete', desc: 'Modifica un appuntamento Confermato', enable : false, visible : false},
        {label: 'Annulla Appuntamento', name: 'deleteDate', iconName: 'utility:delete', desc: 'Annulla un appuntamento non ancora Confermato', enable : false, visible : false},
        {label: 'Riprendi Appuntamento', name: 'resumeDate', iconName: 'utility:record_delete', desc: 'Riprendi un appuntamento non confermato', enable : false, visible : false},
        {label: 'Appuntamento Self', name: 'selfDate', iconName: 'utility:record_delete', desc: 'Invia il link all\'utente per prendere l\'appuntamento in autonomia', enable : false, visible : false}
    ];
    @track params={};
    get stmtValue(){
        return this.tempList;
    }

    @wire(getActivity,{activityId : '$recordId', fields: OBJECT_FIELDS })
    wiredActivity(value){
        console.log('@@@@@isCommunity ' + this.isCommunity);
        this.wiredActivity = value;
        const { data, error } = value; 
        if (data){
            this.activity = JSON.parse(data);
            this.tempList.forEach( item =>{
                let itemName = item.name;
                let enable = false;
                let stato = this.activity.wrts_prcgvr__Status__c;
                if (this.activity.AppointmentCompetence__c != 'Distributore' && this.activity.isAtoA__c){
                    switch (itemName){
                        case 'newDate':
                            item.visible = true;
                            if (NEW_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                        case 'editDate':
                            item.visible = true;
                            let maxDayInMs = this.getMaxDateInMilliseconds(this.activity.MaxDateModificationAppointment__c,this.activity.MaxTimeModificationAppointment__c); 
                            let nowInMs = Date.now();
                            if (EDIT_DATE_VALID_STATE.indexOf(stato) != -1 && maxDayInMs != -1 && nowInMs < maxDayInMs){
                                enable = true;
                            }
                        break;
                        case 'deleteDate':
                            item.visible = true;
                            if (DELETE_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                        case 'resumeDate':
                            item.visible = true;
                            if (RESUME_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                        case 'selfDate':
                            item.visible = !this.isCommunity;
                            if (SELF_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                    }
                } 
                item.enable = enable; 
            });
            this.showAgenda = false;
            this.showForm = false;
        }else if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
    }
    
    clickOperation(event){
        let showAgenda = true;
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
            case 'selfDate':
                showAgenda = false;
            break;
        }
        if (showAgenda){
            this.params = {...this.params,userCommunity : this.isCommunity};
            this.showAgenda = showAgenda;
        }else{
            this.showForm = true;
        }
        
    }

    cancelEvent(event){
        this.params = {};
        if(event.detail === true){
            if (this.isCommunity){
                let myWiredActivity = this.wiredActivity;
                setTimeout(function(){refreshApex(myWiredActivity)},5000);
            }else{
                window.location.reload();
            }
        }else{
            this.showAgenda = false;
            this.showForm = false;
        }
        
    }

    

    

    //return date + time in ms
    getMaxDateInMilliseconds(dateToWork,timeToWork){
        let dateToFormat = dateToWork+' '+this.formatTime(timeToWork);
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
            let timeInArray = timeToFormat.replace(' ','').split(':');
            let formattedDate = '';
            timeInArray.forEach((item,index) => {
                if (index < 3){
                    item = (item.lenght === 1) ? '0'+item : item;
                    formattedDate += item + ':';
                }
            });
            if (timeInArray.length == 3){
                return formattedDate.substring(0,formattedDate.length - 1);
            }else if (timeInArray.length == 2){
                return formattedDate + '00';
            }
        }
        return -1;
    }
}