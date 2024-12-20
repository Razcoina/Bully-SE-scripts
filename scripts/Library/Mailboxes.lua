function F_RichAreaMailboxesCreate()
	shared.MailboxesRespawn = MAILBOXES_NONE

	if gRichMailboxes then
		return
	end
	gRichMailboxes = {}
	local index, simpleObject = CreatePersistentEntity("DPE_RCMail", 526.272, 241.001, 16.4327, -1.00179, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 547.044, 249.465, 16.7161, 90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 532.236, 272.267, 16.826, -90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 547.113, 305.33, 17.1062, 90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 546.79, 334.237, 17.0143, 90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 515.632, 340.645, 16.8396, -1.00179, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 486.719, 371.387, 17.0019, -90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 536.571, 354.229, 16.6482, 180, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 596.986, 352.055, 15.8196, 45, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 598.178, 394.361, 16.5065, 90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 547, 443.638, 17.3933, -90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 554.955, 479.848, 18.3663, 90.0001, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 552.537, 531.091, 23.893, 135, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 517.474, 546.729, 24.1603, -180, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 445.055, 527.075, 22.0537, -180, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 437.434, 514.196, 22.144, 5.46415, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 398.211, 513.465, 22.3977, -135, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 376.662, 437.819, 21.7101, -135, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 310.277, 437.765, 21.6598, -135, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 348.49, 419.003, 21.5763, -32.5048, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 491.158, 516.609, 19.6608, 37.0387, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 624.461, 219.376, 17.1449, -39.8904, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 546.659, 197.626, 16.8088, 90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	index, simpleObject = CreatePersistentEntity("DPE_RCMail", 532.071, 168.005, 15.6071, -90, 0)
	table.insert(gRichMailboxes, { id = index, object = simpleObject })
	--print(">>>[RUI]", "++F_RichAreaMailboxesCreate " .. tostring(table.getn(gRichMailboxes)))
end

function F_RichAreaMailboxesRemove()
	shared.MailboxesRespawn = MAILBOXES_NONE
	if not gRichMailboxes then
		return
	end
	for _, mbox in gRichMailboxes do
		if mbox.id and mbox.object and mbox.id ~= -1 and mbox.object ~= -1 then
			DeletePersistentEntity(mbox.id, mbox.object)
			mbox = nil
		end
	end
	gRichMailboxes = nil
	collectgarbage()
	--print(">>>[RUI]", "--F_RichAreaMailboxesRemove")
end
