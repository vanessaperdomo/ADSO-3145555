package com.sena.test.IService.IBillService;

import com.sena.test.DTO.BillDTO.InvoiceDto;
import java.util.List;
import java.util.UUID;

public interface IInvoiceService {
    List<InvoiceDto> getAll();

    InvoiceDto getById(UUID id);

    InvoiceDto create(InvoiceDto dto);

    InvoiceDto update(UUID id, InvoiceDto dto);

    void delete(UUID id);
}