import { LightningElement, api, track,wire } from 'lwc';
import getCase from '@salesforce/apex/HDT_LC_AppointmentAgenda.getCase';
import { refreshApex } from '@salesforce/apex';

const OBJECT_FIELDS =[
    'Id',
    'Phase__c',
    'StartAppointment__c'
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
    @track isViewAppointmentEnabled = false; 
    
    @track tempList = [
        {label: 'Prendi Appuntamento ', name: 'newDate', iconName: 'utility:retail_execution', desc: 'Prendi un nuovo appuntamento con il DL', enable : false, visible : true},
        {label: 'Visualizza Appuntamento', name: 'viewDate', iconName: 'utility:record_delete', desc: 'Visualizza il tuo appuntamento', enable : false, visible : true}
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
                                if(this.case.Phase__c == 'In attesa Appuntamento'){
                                    item.enable = true;
                                }
                            break;
                            case 'viewDate':
                                if(this.case.StartAppointment__c!= null && this.case.Phase__c != 'Completata' && this.case.Phase__c != 'Annullato'){
                                    item.visible = true;
                                    item.enable = true;
                                }
                            break;
                        }
                    } 
                });
            }
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
            case 'viewDate':
                this.params ={
                    method : 'handleView',
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