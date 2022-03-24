import { LightningElement,api,wire,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivityOwner  from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getActivityOwner';
import GETLINK from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getLink';


export default class HdtAppointmentQuickLink extends LightningElement {

    @api recordId;
    activity = {};
    response;
    @track link;
    @track errMessage;

    @wire(GETLINK,{recordId: '$recordId'})
    handleGetDistributor({error,data}){
        if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }else if (this.recordId){
            getActivityOwner({activityId: this.recordId}).then(notMyOwner => {
                if (notMyOwner === true || notMyOwner === 'true'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'L\'attività può essere gestita solo dall\'assegnatario.',
                            variant: 'error',
                        }),
                    );
                    this.closeQuickAction();
                }else{
                    this.getLinkDistributore(data);
                }
            });
        }
        console.log('esco ');
    }

    getLinkDistributore(result){
        if(result!=null){
            this.response=JSON.parse(result); 
            if (this.response.errorMessage) {
                this.errMessage=this.response.errorMessage;
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
            this.showWarningToast();
            this.closeQuickAction();
        }
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