package com.sena.test.IService.IBillService;

import com.sena.test.DTO.BillDTO.PaymentDto;
import java.util.List;
import java.util.UUID;

public interface IPaymentService {
    List<PaymentDto> getAll();

    PaymentDto getById(UUID id);

    PaymentDto create(PaymentDto dto);

    void delete(UUID id);
}