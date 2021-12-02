import { LightningElement, api, track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

const OBJECT_FIELDS =[
    'wrts_prcgvr__Activity__c.MaxTimeModificationAppointment__c',
    'wrts_prcgvr__Activity__c.MaxDateModificationAppointment__c',
    'wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c'
    
];

const NEW_DATE_VALID_STATE = ['Creata'];
const DELETE_DATE_VALID_STATE = ['Presa appuntamento in corso'];
const EDIT_DATE_VALID_STATE = ['Appuntamento confermato'];
const RESUME_DATE_VALID_STATE = ['Presa appuntamento in corso'];



export default class HdtAppointmentHandler extends LightningElement{
    @api recordId;
    showAgenda = false;
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

    @wire(getRecord, { recordId: '$recordId', fields: OBJECT_FIELDS })
    wiredRecord({ error, data }) {
        this.showAgenda = false;
        if (data || error){
            this.tempList.forEach( item =>{
                let itemName = item.name;
                let enable = false;
                if (data){
                    this.activity = data; 
                    let stato = data.fields.wrts_prcgvr__Status__c.value;
                    switch (itemName){
                        case 'newDate':
                            if (NEW_DATE_VALID_STATE.indexOf(stato) != -1){
                                enable = true;
                            }
                        break;
                        case 'editDate':
                            let maxDayInMs = this.getMaxDateInMilliseconds(data.fields.MaxDateModificationAppointment__c.value,data.fields.MaxTimeModificationAppointment__c.value); 
                            let nowInMs = Date.now();
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
        this.showAgenda = true;
    }

    cancelEvent(event){
        this.params = {};
        updateRecord({ fields: { Id: this.recordId } });
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
            let firstProcess = timeToFormat.split('T');
            let timeInArray = firstProcess[0].replace(' ','').split(':');
            let formattedDate = '';
            timeInArray.forEach((item,index) => {
                if (index < 3){
                    item = item > 9 ? item : '0'+item;
                }else if (index === 3){
                    if (item < 10){
                        item = '00' + item;
                    }else if (item < 100){
                        item = '0' + item;
                    }
                }
                formattedDate += item + ':';
            });
            if (timeInArray.length == 4){
                return formattedDate.substring(0,formattedDate.length - 1);
            }else if (timeInArray.length == 3){
                return formattedDate + '000';
            }
        }
        return -1;
    }
}