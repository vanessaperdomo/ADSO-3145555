package com.sena.test.Controller.BillController;

import com.sena.test.DTO.BillDTO.InvoiceDto;
import com.sena.test.Service.BillService.InvoiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/invoice")
@CrossOrigin(origins = "*")
public class InvoiceController {

    @Autowired
    private InvoiceService invoiceService;

    @GetMapping
    public List<InvoiceDto> getAll() {
        return invoiceService.getAll();
    }

    @GetMapping("/{id}")
    public InvoiceDto getById(@PathVariable UUID id) {
        return invoiceService.getById(id);
    }

    @PostMapping
    public InvoiceDto create(@RequestBody InvoiceDto dto) {
        return invoiceService.create(dto);
    }

    @PutMapping("/{id}")
    public InvoiceDto update(@PathVariable UUID id, @RequestBody InvoiceDto dto) {
        return invoiceService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        invoiceService.delete(id);
        return "Eliminado exitosamente";
    }
}