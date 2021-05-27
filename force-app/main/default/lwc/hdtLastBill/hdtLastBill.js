import { LightningElement, track } from 'lwc';
import imageResource from '@salesforce/resourceUrl/HDT_Service1';


const billsColumns = [
    { label: 'Numero bolletta', fieldName: 'billNumber'},
    { label: 'Importo', fieldName: 'amount', type: 'currency'},
    { label: 'Stato', fieldName: 'status'}
    /*{ label: 'Data lettura', fieldName: 'lectureDate'},
    { label: 'Fascia', fieldName: 'slot'},
    { label: 'Lettura (Interi)', fieldName: 'lectureInt'},
    { label: 'Lettura (Decimal)', fieldName: 'lectureDecimal'},
    { label: 'Consumo', fieldName: 'consumed'},
    { label: 'Codice Apparecchio', fieldName: 'assetCode'},
    { label: 'Codice Contratto', fieldName: 'contractCode'},
    { label: 'Stato', fieldName: 'status'},
    { label: 'Tipo lettura', fieldName: 'lectureType'},
    { label: 'Causale', fieldName: 'reason'},
    { label: 'Giorni di fatturazione', fieldName: 'billingDate'},
    { label: 'Consumo medio', fieldName: 'consumedAvg'},
    { label: 'Tipo registro', fieldName: 'regType'},
    { label: 'Consumo', fieldName: 'consumed'},
    { label: 'Unità di misura', fieldName: 'meters'},
    { label: 'Tipo di consumo', fieldName: 'consumedType'},
    { label: 'Settore merceologico', fieldName: 'sector'},
    { label: 'Flag lettura', fieldName: 'consumed'},
    { label: 'Motivazione', fieldName: 'reasonWhy'}*/
];

const billsData = [
    {id: '1', billNumber: '012589', amount: '105', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Pagato', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '2', billNumber: '098754', amount: '310', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Non pagato', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '3', billNumber: '058478', amount: '501', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Non Pagato', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    /*{id: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '5', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '6', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '7', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '8', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '9', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '10', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '11', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '12', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    {id: '13', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0000', consumed: '0.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
*/
];


export default class HdtLastBill extends LightningElement {

    @track iconUrl = imageResource;
    @track billsColumns = billsColumns;
    @track billsData = billsData;

    get counter(){
        return billsData.length;
    }

    connectedCallback(){
        console.log('image url: ' + this.iconUrl);
    }

}