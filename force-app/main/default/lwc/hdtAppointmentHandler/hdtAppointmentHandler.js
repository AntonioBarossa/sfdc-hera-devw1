import { LightningElement, api, track,wire } from 'lwc';
import getActivity from '@salesforce/apex/HDT_LC_AppointmentAgenda.getActivity';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivityOwner  from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getActivityOwner';




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
    'isAtoA__c',
    'Type__c',
    'ContactResult__c'
    
];


export default class HdtAppointmentHandler extends LightningElement{
    showAgenda = false;
    showForm = false;
    hasRendered = false;
    variant='offline';
    alertMessage = 'Per prendere l\'appuntamento seleziona Prendi Appuntamento. Una volta confermato l\'appuntamento non sarà possibile modificarlo o annullarlo in autonomia ma sarà necessario contattare il servizio clienti. Ti ricordiamo che hai a disposizione 24 ore per prendere l\'appuntamento.';
    @api confirmed = false;
    @api isCommunity = false;
    @api recordId;
    isNotOwner;
    
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
        this.wiredActivity = value;
        const { data, error } = value; 
        if (data){
            this.activity = JSON.parse(data);
            console.log('data: ' + data);
            console.log('data stringified: ' + JSON.stringify(data));
            let stato = this.activity.wrts_prcgvr__Status__c;
            let tipoAttivita = this.activity.Type__c;
            let esitoContatto = this.activity.ContactResult__c;
            if((stato=='Appuntamento confermato' || stato=='Modifica confermata') && this.isCommunity){
                this.confirmed=true;
            }
            if(stato=='Appuntamento di competenza Distributore'){
                this.alertMessage = 'L\'appuntamento è in carico al distributore che la contatterà per fissare un appuntamento.'
                this.variant = 'error';
            }
            if(this.confirmed==false){
                this.tempList.forEach( item =>{
                    let itemName = item.name;
                    let enable = false;
                    
                    if (this.activity.AppointmentCompetence__c != 'Distributore' && this.activity.isAtoA__c){
                        switch (itemName){
                            case 'newDate':
                                item.visible = true;
                                if (NEW_DATE_VALID_STATE.indexOf(stato) != -1){
                                    enable = true;
                                }
                            break;
                            case 'editDate':
                                item.visible = !this.isCommunity;
                                let maxDayInMs = this.getMaxDateInMilliseconds(this.activity.MaxDateModificationAppointment__c,this.activity.MaxTimeModificationAppointment__c); 
                                let nowInMs = Date.now();
                                if (EDIT_DATE_VALID_STATE.indexOf(stato) != -1 && maxDayInMs != -1 && nowInMs < maxDayInMs){
                                    enable = true;
                                }
                            break;
                            case 'deleteDate':
                                item.visible = true;
                                if (DELETE_DATE_VALID_STATE.indexOf(stato) != -1 || (esitoContatto === 'Terzo contatto fallito' && tipoAttivita === 'Presa Appuntamento' && stato === 'Creata')){
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
            }
            this.showAgenda = false;
            this.showForm = false;
        }else if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
    }
    
    clickOperation(event){
        if(this.isCommunity){
            this.showAgendaForm(event.currentTarget.name);
        }
        else{
            let btnName = event.currentTarget.name;
            getActivityOwner({activityId: this.recordId}).then(data => {
                this.isNotOwner = data;
                if (this.isNotOwner === 'true' || this.isNotOwner === true){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'L\'attività può essere gestita solo dall\'assegnatario.',
                            variant: 'error',
                        }),
                    );
                }
                else{
                    this.showAgendaForm(btnName);
                }
            });


        }
    }

    showAgendaForm(btnName){
        console.log('btnName --> '+btnName);
        let showAgenda = true;
        switch (btnName){
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