package com.sena.test.Controller.BillController;

import com.sena.test.DTO.BillDTO.PaymentDto;
import com.sena.test.Service.BillService.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/payment")
@CrossOrigin(origins = "*")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @GetMapping
    public List<PaymentDto> getAll() {
        return paymentService.getAll();
    }

    @GetMapping("/{id}")
    public PaymentDto getById(@PathVariable UUID id) {
        return paymentService.getById(id);
    }

    @PostMapping
    public PaymentDto create(@RequestBody PaymentDto dto) {
        return paymentService.create(dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        paymentService.delete(id);
        return "Eliminado exitosamente";
    }
}