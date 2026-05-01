package com.sena.test.IService.IBillService;

import com.sena.test.DTO.BillDTO.MethodPaymentDto;
import java.util.List;
import java.util.UUID;

public interface IMethodPaymentService {
    List<MethodPaymentDto> getAll();

    MethodPaymentDto getById(UUID id);

    MethodPaymentDto create(MethodPaymentDto dto);

    MethodPaymentDto update(UUID id, MethodPaymentDto dto);

    void delete(UUID id);
}