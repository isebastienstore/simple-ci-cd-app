import { IAuthority, NewAuthority } from './authority.model';

export const sampleWithRequiredData: IAuthority = {
  name: '5f257c5d-8270-405b-b021-bd31b95e722c',
};

export const sampleWithPartialData: IAuthority = {
  name: '96f95380-c069-4008-a007-074e3bb021b4',
};

export const sampleWithFullData: IAuthority = {
  name: 'b085af1d-7b6a-49b7-a308-77cd108dfb7a',
};

export const sampleWithNewData: NewAuthority = {
  name: null,
};

Object.freeze(sampleWithNewData);
Object.freeze(sampleWithRequiredData);
Object.freeze(sampleWithPartialData);
Object.freeze(sampleWithFullData);
