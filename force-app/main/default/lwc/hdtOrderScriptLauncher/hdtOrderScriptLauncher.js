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
            console.log('isChannelEnabled: ' + isChannelEnabled);
            let signatureMethod = this.order.fields.SignatureMethod__c.value;
            console.log('signatureMethod: ' + signatureMethod);
            let isSignatureEnabled = (SCRIPT_SIGNATURE_METHODS.indexOf(signatureMethod)>=0);
            console.log('isSignatureEnabled: ' + isSignatureEnabled);
            console.log('Status Order: ' + this.order.fields.Status.value);

            return (this.order.fields.Status.value=='In Lavorazione' && isChannelEnabled && isSignatureEnabled);
        }
        else return false;
    }

    showModal() {
        this.template.querySelector('c-hdt-manage-script-modal').showModal();
    }
}