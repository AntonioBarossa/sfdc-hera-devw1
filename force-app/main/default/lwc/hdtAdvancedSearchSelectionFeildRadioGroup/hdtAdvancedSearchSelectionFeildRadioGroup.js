import { LightningElement, track,api,wire } from 'lwc';
import imageResource from '@salesforce/resourceUrl/HDT_Service1';
import imageResource2 from '@salesforce/resourceUrl/HDT_Service2';
import imageResource3 from '@salesforce/resourceUrl/HDT_Service3';
import imageResource4 from '@salesforce/resourceUrl/HDT_Service4';

export default class HdtAdvancedSearchSelectionFeildRadioGroup extends LightningElement {

    eleUrl = imageResource;
    gasUrl = imageResource2;
    acquaUrl = imageResource3;
    ambienteUrl = imageResource4;

    imagesPodPdr = [this.eleUrl, this.gasUrl] ;
    imagesPuntoPresa = [this.acquaUrl];
    imagesMatricolaContatore = [this.eleUrl, this.gasUrl, this.acquaUrl];
    imagesCodiceContratto = [this.eleUrl, this.gasUrl, this.acquaUrl, this.ambienteUrl];
    imagesIndirizzo = [this.ambienteUrl];
    imagesDatiCatastali = [this.ambienteUrl];

    
    @track options = [];
    @api rowId;

    connectedCallback(){
            this.options.push({key: 1, label: 'Codice POD/PDR ', imageName: this.imagesPodPdr, value: 'pod', checked: true });
            this.options.push({key: 2, label: 'Codice Punto Presa ', imageName: this.imagesPuntoPresa, value: 'podH2o', checked: '' });
            this.options.push({key: 3, label: 'Matricola contatore ', imageName: this.imagesMatricolaContatore, value: 'serialnumber', checked: '' });
            this.options.push({key: 4, label: 'Codice Contratto ', imageName: this.imagesCodiceContratto, value: 'contract', checked: '' });
            this.options.push({key: 5, label: 'Indirizzo di fornitura ', imageName: this.imagesIndirizzo, value: 'address', checked: '' });
            this.options.push({key: 6, label: 'Dati Catastali ', imageName: this.imagesDatiCatastali, value: 'datiCatastali', checked: '' });
    }

    handleSelected(event) {
        //window.console.log('selected value ===> '+event.target.value + ' on row -> ' + this.rowId);
        this.value = event.target.value;

        this.options.forEach(opt => {
            if (opt.value === this.value) {
                opt.checked = true;
            } else {
                opt.checked = false;
            }
        });

        
        console.log('#Selected and ready to dispatch: ' + this.value);
        const valueEvent = new CustomEvent('changevalue', {detail: this.value});
        this.dispatchEvent(valueEvent);
        
     }

}