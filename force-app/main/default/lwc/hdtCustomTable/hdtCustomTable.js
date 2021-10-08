import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const actions = [
    { label: 'Dettagli', name: 'show_details' },
 
];
const columns = [
    { label: 'Referente', fieldName: 'contactName' },
    { label: 'Ruolo', fieldName: 'roles' },
    { label: 'Telefono Cellulare', fieldName: 'contactMobilePhone' },
    { label: 'Telefono fisso', fieldName: 'contactHomePhone' },
    { label: 'Email', fieldName: 'contactEmail' },
    { label: 'BP Interlocutore', fieldName: 'bpInterlocutor' },
    { label: 'Data inizio validità', fieldName: 'startDate' },
    { label: 'Data fine validità', fieldName: 'endDate' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
]
export default class HdtCustomTable extends NavigationMixin(LightningElement)  {

    @track columns=columns;

    @api mydata;

    connectedCallback() {
      
        
    }

    handleRowAction(event) {
        const row = event.detail;
        console.log(' '+JSON.stringify(row['row'].contactId));
        this.genericRedirect(row['row'].contactId,'Contact');   
    }

    genericRedirect(recordId,obj){
       
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: obj,
                actionName: 'view'
            },
        });
    }


}