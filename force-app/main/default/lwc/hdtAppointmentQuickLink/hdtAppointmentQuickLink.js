import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GETLINK from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getLink';
import ID_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.Id';
import DIST_NAME from '@salesforce/schema/wrts_prcgvr__Activity__c.Distributor__r.Name';

const OBJECT_FIELDS =[
    ID_FIELD,
    DIST_NAME
];

export default class HdtAppointmentQuickLink extends LightningElement {

    @api recordId;
    activity = {};
    response;
    @track link;
    @track errMessage;

    @wire(getRecord,{recordId : '$recordId', fields: OBJECT_FIELDS })
    wireRecord({error,data}){
        if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
        if (data){
            this.activity = data;
            //console.log('@@@@data wired method ' + JSON.stringify(data));

            //console.log("@Dist: "+distributore);

            this.getLinkDistributore(this.recordId);
        }
    }

    getLinkDistributore(actId){
        
       // console.log("@ID: "+actId);

        GETLINK({recordId: actId})
        .then(result => {
            if(result!=null){
                this.response=JSON.parse(result); 
                if (this.response.errorMessage) {
                    this.errMessage=this.response.errorMessage;
                    //console.log('@@@error ' +this.errMessage);
                    this.showWarningToast();
                    this.closeQuickAction();
                } else {
                    this.link=this.response.link;
                    window.open(this.link);  
                    this.closeQuickAction();     
                }
            }
            else{
                this.errMessage='Nessun Distributore trovato per questa Attività';
                    //console.log('@@@error ' +this.errMessage);
                    this.showWarningToast();
                    this.closeQuickAction();
            }

        })
    }

    showWarningToast() {
        const evt = new ShowToastEvent({
            title: 'Attenzione',
            message: this.errMessage,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}