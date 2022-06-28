import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const actions = [
    { label: 'Dettagli', name: 'show_details' },
 
];
const columns = [
    {
        label: 'Referente', fieldName: 'contactUrl', type: 'url',initialWidth:200,
        typeAttributes: {
            label: {
                fieldName: 'contactName'
            }
        }
    },
    { label: 'Ruolo', fieldName: 'roles',initialWidth:200 },
    { label: 'Telefono Cellulare', fieldName: 'contactMobilePhone',initialWidth:200 },
    { label: 'Telefono fisso', fieldName: 'contactHomePhone',initialWidth:200 },
    { label: 'Email', fieldName: 'contactEmail',initialWidth:200 },
  //{ label: 'BP Interlocutore', fieldName: 'bpInterlocutor' },
    { label: 'Codice Contatto', fieldName: 'contactCode',initialWidth:200 },
    { label: 'Data inizio validità', fieldName: 'startDate',initialWidth:200 },
    { label: 'Data fine validità', fieldName: 'endDate',initialWidth:200 },
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