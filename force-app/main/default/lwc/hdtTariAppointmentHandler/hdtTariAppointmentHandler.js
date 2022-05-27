import { LightningElement, api, track,wire } from 'lwc';
import getCase from '@salesforce/apex/HDT_LC_AppointmentAgenda.getCase';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivityOwner  from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getActivityOwner';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const NEW_DATE_VALID_STATE = ['Creata','Invio app.to SELF cliente'];
const SELF_DATE_VALID_STATE = ['Creata'];
const DELETE_DATE_VALID_STATE = ['Presa appuntamento in corso'];
const EDIT_DATE_VALID_STATE = ['Appuntamento confermato','Modifica confermata'];
const RESUME_DATE_VALID_STATE = ['Presa appuntamento in corso'];
const OBJECT_FIELDS =[
    'Id'
    
];


export default class HdtTariAppointmentHandler extends LightningElement{
    showAgenda = false;
    showForm = false;
    hasRendered = false;
    variant='offline';
    alertMessage = 'Per prendere l\'appuntamento seleziona Prendi Appuntamento. Una volta confermato l\'appuntamento non sarà possibile modificarlo o annullarlo in autonomia ma sarà necessario contattare il servizio clienti. Ti ricordiamo che hai a disposizione 24 ore per prendere l\'appuntamento.';
    @api confirmed = false;
    @api isCommunity = false;
    @api recordId;
    isNotOwner;
    @track params={};
    
    @track tempList = [
        {label: 'Prendi Appuntamento ', name: 'newDate', iconName: 'utility:retail_execution', desc: 'Prendi un nuovo appuntamento con il DL', enable : true, visible : true},
        {label: 'Visualizza Appuntamento', name: 'viewDate', iconName: 'utility:record_delete', desc: 'Visualizza il tuo appuntamento', enable : false, visible : false}
    ];
    
    get stmtValue(){
        return this.tempList;
    }

    @wire(getCase,{caseId : '$recordId', fields: OBJECT_FIELDS })
    wiredCase(value){
        this.wiredCase = value;
        const { data, error } = value; 
        console.log('value ->'+ value);
        if (data){
            this.case = JSON.parse(data);
            console.log('case ->' + this.case);
            if(this.confirmed==false){
                this.tempList.forEach( item =>{
                    let itemName = item.name;
                    let enable = false;
                    console.log('item -> ' + item);
                    if (true){
                        switch (itemName){
                            case 'newDate':
                                // item.visible = true;
                                // enable = true;
                            break;
                            case 'viewDate':
                                //     item.visible = !this.isCommunity;
                                //     let maxDayInMs = this.getMaxDateInMilliseconds(this.activity.MaxDateModificationAppointment__c,this.activity.MaxTimeModificationAppointment__c); 
                                //     let nowInMs = Date.now();
                                //     if (EDIT_DATE_VALID_STATE.indexOf(stato) != -1 && maxDayInMs != -1 && nowInMs < maxDayInMs){
                                //         enable = true;
                                //     }
                            break;
                        }
                    } 
                    // item.enable = enable; 
                });
            }
            // this.showAgenda = false;
            // this.showForm = false;
        }else if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
    }
    
    clickOperation(event){
        event.preventDefault();
        this.showAgendaForm(event.currentTarget.name);
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
            case 'viewDate': //viewDate TODO
                this.params ={
                    method : 'handleSearch',
                    searchType : 'View'
                };
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
                let myWiredCase = this.wiredCase;
                setTimeout(function(){refreshApex(myWiredCase)},5000);
            }else{
                window.location.reload();
            }
        }else{
            this.showAgenda = false;
            this.showForm = false;
        }
        
    }

}