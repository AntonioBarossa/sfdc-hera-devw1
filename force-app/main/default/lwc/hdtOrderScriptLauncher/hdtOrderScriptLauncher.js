import { LightningElement, api } from 'lwc';

const SCRIPT_SIGNATURE_METHODS = [
    'Vocal Order',
    'OTP Remoto',
    'OTP Coopresenza'
];

const SCRIPT_ENABLED_CHANNELS = [
    'Teleselling',
    'Telefono Outbound',
    'Telefono Inbound'
];

export default class HdtOrderScriptLauncher extends LightningElement {

    @api orderId;
    @api order;

    get isScriptBtnVisible(){
        if (this.order) {

            let loginChannel = this.order.fields.CreatedBy.value.fields.LoginChannel__c.value;
            let isChannelEnabled = (loginChannel==null || SCRIPT_ENABLED_CHANNELS.indexOf(loginChannel)>=0);

            let signatureMethod = this.order.fields.SignatureMethod__c.value;
            let isSignatureEnabled = (SCRIPT_SIGNATURE_METHODS.indexOf(signatureMethod)>=0);

            return (this.order.fields.Status.value=='In Lavorazione' /*&& !hiddenEdit*/ && isChannelEnabled && isSignatureEnabled);
        }
        else return false;
    }

    showModal() {
        this.template.querySelector('c-hdt-manage-script-modal').showModal();
    }

    /*loadScriptMap() {
        getSignatureScript({orderParentId: this.recordId}).then(scriptMap => {
            console.log('getSignatureScript: '+JSON.stringify(scriptMap));
            this.scriptMap = scriptMap;
        });
    }*/
}