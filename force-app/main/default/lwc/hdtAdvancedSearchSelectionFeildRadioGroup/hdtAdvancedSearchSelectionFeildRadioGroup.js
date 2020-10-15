import {LightningElement, api} from 'lwc';

export default class HdtAdvancedSearchSelectionFeildRadioGroup extends LightningElement {

    @api value;

    get options() {
        return [
            {label: 'Codice POD/PDR', value: 'pod'},
            {label: 'Codice Contratto', value: 'contract'},
            {label: 'Matricola contatore', value: 'serialnumber'}
        ];
    }

    handleChange(event) {
        let selected = event.target.value;
        const selectedEvent = new CustomEvent('selected', {detail: selected});
        this.dispatchEvent(selectedEvent);
    }
}