import {LightningElement, api} from 'lwc';

export default class HdtAdvancedSearchSelectionFeildRadioGroup extends LightningElement {

    @api value;
    @api disabledinput;

    get options() {
        return [
            {label: 'Codice POD/PDR', value: 'pod'},
            {label: 'Codice Punto Presa (Acqua)', value: 'podH2o'},
            {label: 'Codice Contratto', value: 'contract'},
            {label: 'Matricola contatore', value: 'serialnumber'},
            {label: 'Indirizzo di fornitura (Ambiente)', value: 'address'}
        ];
    }

    handleChange(event) {
        let selected = event.target.value;
        const selectedEvent = new CustomEvent('selected', {detail: selected});
        this.dispatchEvent(selectedEvent);
    }
}