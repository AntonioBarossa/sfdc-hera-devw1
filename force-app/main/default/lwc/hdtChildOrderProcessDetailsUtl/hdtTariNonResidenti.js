class comune {
    constructor(name, readOnly, getResident) {
        this.name = name;
        this.readOnly = readOnly;
        this.getResident = getResident;
    }
}

export const cities = [
    new comune("BORGO TOSSIGNANO", false, ()=>2),
    new comune("MORINO", false, ()=>2),
    new comune("MODENA", false, (mq) => {
        if (mq <= 50)   return 1;
        if (mq <= 80)   return 2;
        if (mq <= 100)  return 3;
        if (mq <= 120)  return 4;
        if (mq <= 140)  return 5;
        return 6;
    })
]
.reduce((result, elem)=>{
    result[elem.name] = elem;
    return result;
}, {});