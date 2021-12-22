import { LightningElement,api } from 'lwc';

const ALERT_VARIANTS = {
    valid: ['base', 'error', 'offline', 'warning'],
    default: 'base'
};
export default class HdtAppointmentAlert extends LightningElement {
    @api iconName;
    @api closeAction;

    hideAlert;
    _variant = ALERT_VARIANTS.default;
    _isDismissible = false;

    @api
    get variant() {
        return this._variant;
    }

    set variant(variant) {
        if (variant && ALERT_VARIANTS.valid.indexOf(variant) != -1){
            this._variant = variant;
        }else{
            this._variant = ALERT_VARIANTS.default;
        }
    }

    @api
    get isDismissible() {
        return this._isDismissible;
    }
    set isDismissible(value) {
        this._isDismissible = value;
    }

    get variantInverse() {
        return this.variant === 'warning' ? 'bare' : 'inverse';
    }

    get iconClass() {
        return this.variant === 'warning' ? '' : 'slds-button_icon-inverse';
    }

    get variantClass() {
        let newClass = 'slds-notify slds-notify_alert';
            if(this.variant === 'base'){
                newClass+=' slds-theme_info';
            }else if (this.variant === 'error'){
                newClass+=' slds-theme_error';
            }else if (this.variant === 'offline'){
                newClass+=' slds-theme_offline';
            }else if (this.variant === 'warning'){
                newClass+=' slds-theme_warning';
            }
        return newClass;
    }

    closeAlert() {
        this.hideAlert = true;
        this.closeAction();
    }
}