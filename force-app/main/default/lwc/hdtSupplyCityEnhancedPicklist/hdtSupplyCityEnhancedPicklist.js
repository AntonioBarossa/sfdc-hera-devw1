import { LightningElement, api, track} from 'lwc';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';

const CLOSED_CSS = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
const OPENED_CSS = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
export default class HdtSupplyCityEnhancedPicklist extends LightningElement {
    
    @api get label(){
        return this._label;
    }
    set label(newValue){
        if(this._label != newValue) this._label = newValue;
    }
    @api inputSupplyCity;
    @api required;
    @api outputSupplyCity;

    @api validate (){
        let isValid = this.required ? this.outputSupplyCity != null : true;
        let msg = isValid? null : 'Selezionare un comune';
        return { isValid : isValid, errorMessage: msg };
    }

    @track textInputValue = null;

    _label = 'Comune di fornitura';
    cityTechnicalData = [];
    cityOptions = [];

    get valueSelected(){
        return this.outputSupplyCity != null && this.outputSupplyCity !== "";
    }
    
    get cityFilteredOptions(){
        this.setContainerCss(CLOSED_CSS);
        if(this.textInputValue != null && this.textInputValue.length > 2){
            let filteredOptions = [];
            this.cityOptions.forEach( curOpt => {
                if(curOpt.value.toUpperCase().includes(this.textInputValue.toUpperCase())) filteredOptions.push(curOpt);
            });
            if(filteredOptions.length > 0) this.setContainerCss(OPENED_CSS);
            return filteredOptions;
        }
        else return null;
    }

    connectedCallback(){
        this.outputSupplyCity = this.inputSupplyCity;
        this.call_getCities();
    }

    call_getCities() {
        console.log('### call_getCities');
        this.showSpinner = true;
        getCities({ })
            .then(result => {
                console.log('### result -> getCities', JSON.stringify(result.length));
                this.cityTechnicalData = result;
                for (var i = 0; i < result.length; i++) {
                    this.cityOptions=[...this.cityOptions,{label: result[i].CadastralCity__c , value: result[i].CadastralCity__c} ];
                }
            })
            .catch(error => {
                console.error("### call_getCities Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleTextKeyup(event) {
        this.textInputValue = event.target.value;
    }

    handleRemoveButton(){
        this.outputSupplyCity = null;
        this.textInputValue = null;
    }

    handleOptionClick(event){
        this.setContainerCss(CLOSED_CSS);
        this.outputSupplyCity = event.target.getAttribute('data-id');
    }

    setContainerCss(cssValue){
        if(this.template.querySelector('[data-id="comboboxContainer"]'))
            this.template.querySelector('[data-id="comboboxContainer"]').setAttribute("class", cssValue);
    }
    
}