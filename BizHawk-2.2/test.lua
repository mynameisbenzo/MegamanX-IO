-- MarI/O by SethBling
-- Feel free to use this code, but please do not redistribute it.
-- Intended for use with the BizHawk emulator and Super Mario World or Super Mario Bros. ROM.
-- For SMW, make sure you have a save state named "DP1.state" at the beginning of a level,
-- and put a copy in both the Lua folder and the root directory of BizHawk.



if gameinfo.getromname() == "Mega Man X (USA)" then
	Filename = "DP2.state"
	ButtonNames = {
		"A",
		"B",
		"X",
		"Y",
		"Up",
		"Down",
		"Left",
		"Right",
		"L",
		"R"
	}
end

BoxRadius = 6
InputSize = (BoxRadius*2+1)*(BoxRadius*2+1)

Inputs = InputSize+1
Outputs = #ButtonNames

Population = 300
DeltaDisjoint = 2.0
DeltaWeights = 0.4
DeltaThreshold = 1.0

StaleSpecies = 15

MutateConnectionsChance = 0.25
PerturbChance = 0.90
CrossoverChance = 0.75
LinkMutationChance = 2.0
NodeMutationChance = 0.50
BiasMutationChance = 0.40
StepSize = 0.1
DisableMutationChance = 0.4
EnableMutationChance = 0.2

TimeoutConstant = 40

MaxNodes = 1000000

--position of camera
camX = 0
camY = 0

function getPositions()
	megaHealth = memory.read_s16_le(0x0bcf)
	if gameinfo.getromname() == "Mega Man X (USA)" then
		megaX = memory.read_s16_le(0x0bad)
		megaY = memory.read_s16_le(0x0bb0)

		camX = memory.read_s16_le(0x00b4)
		camY = memory.read_s16_le(0x00b6)
	end
end

-----------------------------------------------------------------------------------------
-- AND THIS IS WHERE THE DANG FLOOR IS RECOGNIZED!!!!
-----------------------------------------------------------------------------------------
function getTile(dx, dy)
	if gameinfo.getromname() == "Mega Man X (USA)" then
		x = math.floor((megaX+dx+8)/16)
		y = math.floor((megaY+dy)/16)
		-- gui.text(x,y,"x")
		return memory.read_s16_le(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10)
	end
end

-----------------------------------------------------------------------------------------
-- NO THIS IS WHERE THE ENEMY SPRITES ARE PUT!!! JEEZ!!!
-----------------------------------------------------------------------------------------
function getSprites()
	if gameinfo.getromname() == "Mega Man X (USA)" then
		local sprites = {}
		for slot=0,15 do
			local number = memory.read_s16_le(0x0E68+(slot*64))
			if number ~= 0 then
				spritex = memory.read_s16_le(0x0E68+0x22)
				spritey = memory.read_s16_le(0x0E68+0x24)
				sprites[#sprites+1] = {["x"]=spritex, ["y"]=spritey}
			end
		end
		return sprites
	end
end

-- get enemies sprites?
-- function getExtendedSprites()
	-- if gameinfo.getromname() == "Mega Man X (USA)" then
		-- local extended = {}
		-- for slot=0,15 do
			-- local number = memory.readbyte(0x0E68+(slot*64))
			-- if number ~= 0 then
				-- spritex = memory.readbyte(0x171F+slot) + memory.readbyte(0x1733+slot)*256
				-- spritey = memory.readbyte(0x1715+slot) + memory.readbyte(0x1729+slot)*256
				-- extended[#extended+1] = {["x"]=spritex, ["y"]=spritey}
			-- end
		-- end

		-- return extended
	-- end
-- end

function getInputs()
	getPositions()

	sprites = getSprites()
	-- extended = getExtendedSprites()

	local inputs = {}

	for dy=-BoxRadius*16,BoxRadius*16,16 do
		for dx=-BoxRadius*16,BoxRadius*16,16 do
			inputs[#inputs+1] = 0

			tile = getTile(dx, dy)
			if tile == 1 and megaY+dy < 0x1b0 then
				inputs[#inputs] = 1
			end

			for i = 1,#sprites do
				distx = math.abs(sprites[i]["x"] - (megaX+dx))
				disty = math.abs(sprites[i]["y"] - (megaY+dy))
				if distx <= 8 and disty <= 8 then
					inputs[#inputs] = -1
				end
			end

			-- for i=1,#extended do
				-- distx = math.abs(extended[i]["x"] - (megaX+dx))
				-- disty = math.abs(extended[i]["y"] - (megaY+dy))
				-- if distx < 8 and disty < 8 then
					-- inputs[#inputs] = -1
				-- end
			-- end
		end
	end

	-- console.writeline("Camera X pos:"..camX)		-- camera xpos
	-- console.writeline("X Sprite pos:"..megaX)						-- mega man x position
	if #sprites > 0 and sprites[1]["x"] ~= 0 then
		-- for i=1,#sprites do
			-- console.writeline(sprites[i]["x"])
			-- console.writeline(megaX)
		-- end
		-- console.writeline("distx:"..distx)
		-- console.writeline("disty:"..disty)
		-- console.writeline("")
		-- console.writeline("starting")
		-- console.writeline(memory.readbyte(0x0e68))	-- object exists or not
		-- console.writeline(memory.readbyte(0x0e69))	-- objects action 1
		-- console.writeline(memory.readbyte(0x0e6a))	-- objects action 2
		-- console.writeline(memory.readbyte(0x0e6b))	-- ???
		-- console.writeline(memory.readbyte(0x0e6c))	-- sub-pixel xpos
		-- console.writeline("Camera X pos:"..memory.readbyte(0x00b4))		-- camera xpos
		-- console.writeline("first xpos:"..memory.readbyte(0x0e6d))	-- xpos in pixels 	--if you see above i was using address 22 bytes away from
						--					the enemy address putting me at a different address that
						--					is listed as having the same title.  I am curious as to
						--					whether or not there is a diffence in each value.
		-- gui.text(megaX, megaY, "x")
		-- gui.text(megaX-camX, megaY-camY, "X")
		-- console.writeline(memory.readbyte(0x0e6e))	-- ???
		-- console.writeline(memory.readbyte(0x0e6f))	-- sub-pixel ypos
		-- console.writeline(memory.readbyte(0x0e70))	-- ypos in pixels	-- see abov xpos in pixels
		-- console.writeline(memory.readbyte(0x0e71))	-- ???
		-- console.writeline(memory.readbyte(0x0e72))	-- object ID
		-- console.writeline(memory.readbyte(0x0e73))	-- ???
		-- console.writeline(memory.readbyte(0x0e74))	-- ???
		-- console.writeline(memory.readbyte(0x0e75))	-- ???
		-- console.writeline(memory.readbyte(0x0e76))	-- ???
		-- console.writeline(memory.readbyte(0x0e77))	-- ???
		-- console.writeline(memory.readbyte(0x0e78))	-- ???
		-- console.writeline(memory.readbyte(0x0e79))	-- ???
		-- console.writeline(memory.readbyte(0x0e7a))	-- ???
		-- console.writeline(memory.readbyte(0x0e7b))	-- Animation countain
		-- console.writeline(memory.readbyte(0x0e7c))	-- ???
		-- console.writeline(memory.readbyte(0x0e7d))	-- ???
		-- console.writeline(memory.readbyte(0x0e7e))	-- ???
		-- console.writeline(memory.readbyte(0x0e7f))	-- Object sprite
		-- console.writeline(memory.readbyte(0x0e80))	-- ???
		-- console.writeline(memory.readbyte(0x0e81))	-- ???
		-- console.writeline(memory.readbyte(0x0e82))	-- xvelocity, sub-pixel per frame
		-- console.writeline(memory.readbyte(0x0e83))	-- ???
		-- console.writeline(memory.readbyte(0x0e84))	-- yvelocity, negative sub-pixel per frame
		-- console.writeline(memory.readbyte(0x0e85))	-- ???
		-- console.writeline(memory.readbyte(0x0e86))	-- y-acceleration, sub-pixels per frame per frame
		-- console.writeline(memory.readbyte(0x0e87))	-- ???
		-- console.writeline(memory.readbyte(0x0e88))	-- ???
		-- console.writeline(memory.readbyte(0x0e89))	-- ???
		-- console.writeline("second xpos:"..memory.read_s16_le(0x0e8a))	-- xpos in pixels
		-- console.writeline(memory.readbyte(0x0e8b))	-- ???
		-- console.writeline(memory.readbyte(0x0e8c))	-- ypos in pixels
		-- console.writeline(memory.readbyte(0x0e8d))	-- ???
		-- console.writeline(memory.readbyte(0x0e8e))	-- ???
		-- console.writeline(memory.readbyte(0x0e8f))	-- current health
		-- console.writeline(memory.readbyte(0x0e90))	-- unknown -24 bytes
		-- console.writeline("done")
	end

	return inputs
end

function sigmoid(x)
	return 2/(1+math.exp(-4.9*x))-1
end
function newInnovation()
	pool.innovation = pool.innovation + 1
	return pool.innovation
end

function newPool()
	local pool = {}
	pool.species = {}
	pool.generation = 0
	pool.innovation = Outputs
	pool.currentSpecies = 1
	pool.currentGenome = 1
	pool.currentFrame = 0
	pool.maxFitness = 0

	return pool
end

function newSpecies()
	local species = {}
	species.topFitness = 0
	species.staleness = 0
	species.genomes = {}
	species.averageFitness = 0

	return species
end

function newGenome()
	local genome = {}
	genome.genes = {}
	genome.fitness = 0
	genome.adjustedFitness = 0
	genome.network = {}
	genome.maxneuron = 0
	genome.globalRank = 0
	genome.mutationRates = {}
	genome.mutationRates["connections"] = MutateConnectionsChance
	genome.mutationRates["link"] = LinkMutationChance
	genome.mutationRates["bias"] = BiasMutationChance
	genome.mutationRates["node"] = NodeMutationChance
	genome.mutationRates["enable"] = EnableMutationChance
	genome.mutationRates["disable"] = DisableMutationChance
	genome.mutationRates["step"] = StepSize

	return genome
end

function copyGenome(genome)
	local genome2 = newGenome()
	for g=1,#genome.genes do
		table.insert(genome2.genes, copyGene(genome.genes[g]))
	end
	genome2.maxneuron = genome.maxneuron
	genome2.mutationRates["connections"] = genome.mutationRates["connections"]
	genome2.mutationRates["link"] = genome.mutationRates["link"]
	genome2.mutationRates["bias"] = genome.mutationRates["bias"]
	genome2.mutationRates["node"] = genome.mutationRates["node"]
	genome2.mutationRates["enable"] = genome.mutationRates["enable"]
	genome2.mutationRates["disable"] = genome.mutationRates["disable"]

	return genome2
end

function basicGenome()
	local genome = newGenome()
	local innovation = 1

	genome.maxneuron = Inputs
	mutate(genome)

	return genome
end

function newGene()
	local gene = {}
	gene.into = 0
	gene.out = 0
	gene.weight = 0.0
	gene.enabled = true
	gene.innovation = 0

	return gene
end

function copyGene(gene)
	local gene2 = newGene()
	gene2.into = gene.into
	gene2.out = gene.out
	gene2.weight = gene.weight
	gene2.enabled = gene.enabled
	gene2.innovation = gene.innovation

	return gene2
end

function newNeuron()
	local neuron = {}
	neuron.incoming = {}
	neuron.value = 0.0

	return neuron
end

function generateNetwork(genome)
	local network = {}
	network.neurons = {}

	for i=1,Inputs do
		network.neurons[i] = newNeuron()
	end

	for o=1,Outputs do
		network.neurons[MaxNodes+o] = newNeuron()
	end

	table.sort(genome.genes, function (a,b)
		return (a.out < b.out)
	end)
	for i=1,#genome.genes do
		local gene = genome.genes[i]
		if gene.enabled then
			if network.neurons[gene.out] == nil then
				network.neurons[gene.out] = newNeuron()
			end
			local neuron = network.neurons[gene.out]
			table.insert(neuron.incoming, gene)
			if network.neurons[gene.into] == nil then
				network.neurons[gene.into] = newNeuron()
			end
		end
	end

	genome.network = network
end

function evaluateNetwork(network, inputs)
	table.insert(inputs, 1)
	if #inputs ~= Inputs then
		console.writeline("Incorrect number of neural network inputs.")
		return {}
	end

	for i=1,Inputs do
		network.neurons[i].value = inputs[i]
	end

	for _,neuron in pairs(network.neurons) do
		local sum = 0
		for j = 1,#neuron.incoming do
			local incoming = neuron.incoming[j]
			local other = network.neurons[incoming.into]
			sum = sum + incoming.weight * other.value
		end

		if #neuron.incoming > 0 then
			neuron.value = sigmoid(sum)
		end
	end

	local outputs = {}
	for o=1,Outputs do
		local button = "P1 " .. ButtonNames[o]
		if network.neurons[MaxNodes+o].value > 0 then
			outputs[button] = true
		else
			outputs[button] = false
		end
	end

	return outputs
end

function crossover(g1, g2)
	-- Make sure g1 is the higher fitness genome
	if g2.fitness > g1.fitness then
		tempg = g1
		g1 = g2
		g2 = tempg
	end

	local child = newGenome()

	local innovations2 = {}
	for i=1,#g2.genes do
		local gene = g2.genes[i]
		innovations2[gene.innovation] = gene
	end

	for i=1,#g1.genes do
		local gene1 = g1.genes[i]
		local gene2 = innovations2[gene1.innovation]
		if gene2 ~= nil and math.random(2) == 1 and gene2.enabled then
			table.insert(child.genes, copyGene(gene2))
		else
			table.insert(child.genes, copyGene(gene1))
		end
	end

	child.maxneuron = math.max(g1.maxneuron,g2.maxneuron)

	for mutation,rate in pairs(g1.mutationRates) do
		child.mutationRates[mutation] = rate
	end

	return child
end

function randomNeuron(genes, nonInput)
	local neurons = {}
	if not nonInput then
		for i=1,Inputs do
			neurons[i] = true
		end
	end
	for o=1,Outputs do
		neurons[MaxNodes+o] = true
	end
	for i=1,#genes do
		if (not nonInput) or genes[i].into > Inputs then
			neurons[genes[i].into] = true
		end
		if (not nonInput) or genes[i].out > Inputs then
			neurons[genes[i].out] = true
		end
	end

	local count = 0
	for _,_ in pairs(neurons) do
		count = count + 1
	end
	local n = math.random(1, count)

	for k,v in pairs(neurons) do
		n = n-1
		if n == 0 then
			return k
		end
	end

	return 0
end

function containsLink(genes, link)
	for i=1,#genes do
		local gene = genes[i]
		if gene.into == link.into and gene.out == link.out then
			return true
		end
	end
end

function pointMutate(genome)
	local step = genome.mutationRates["step"]

	for i=1,#genome.genes do
		local gene = genome.genes[i]
		if math.random() < PerturbChance then
			gene.weight = gene.weight + math.random() * step*2 - step
		else
			gene.weight = math.random()*4-2
		end
	end
end

function linkMutate(genome, forceBias)
	local neuron1 = randomNeuron(genome.genes, false)
	local neuron2 = randomNeuron(genome.genes, true)

	local newLink = newGene()
	if neuron1 <= Inputs and neuron2 <= Inputs then
		--Both input nodes
		return
	end
	if neuron2 <= Inputs then
		-- Swap output and input
		local temp = neuron1
		neuron1 = neuron2
		neuron2 = temp
	end

	newLink.into = neuron1
	newLink.out = neuron2
	if forceBias then
		newLink.into = Inputs
	end

	if containsLink(genome.genes, newLink) then
		return
	end
	newLink.innovation = newInnovation()
	newLink.weight = math.random()*4-2

	table.insert(genome.genes, newLink)
end

function nodeMutate(genome)
	if #genome.genes == 0 then
		return
	end

	genome.maxneuron = genome.maxneuron + 1

	local gene = genome.genes[math.random(1,#genome.genes)]
	if not gene.enabled then
		return
	end
	gene.enabled = false

	local gene1 = copyGene(gene)
	gene1.out = genome.maxneuron
	gene1.weight = 1.0
	gene1.innovation = newInnovation()
	gene1.enabled = true
	table.insert(genome.genes, gene1)

	local gene2 = copyGene(gene)
	gene2.into = genome.maxneuron
	gene2.innovation = newInnovation()
	gene2.enabled = true
	table.insert(genome.genes, gene2)
end

function enableDisableMutate(genome, enable)
	local candidates = {}
	for _,gene in pairs(genome.genes) do
		if gene.enabled == not enable then
			table.insert(candidates, gene)
		end
	end

	if #candidates == 0 then
		return
	end

	local gene = candidates[math.random(1,#candidates)]
	gene.enabled = not gene.enabled
end

function mutate(genome)
	for mutation,rate in pairs(genome.mutationRates) do
		if math.random(1,2) == 1 then
			genome.mutationRates[mutation] = 0.95*rate
		else
			genome.mutationRates[mutation] = 1.05263*rate
		end
	end

	if math.random() < genome.mutationRates["connections"] then
		pointMutate(genome)
	end

	local p = genome.mutationRates["link"]
	while p > 0 do
		if math.random() < p then
			linkMutate(genome, false)
		end
		p = p - 1
	end

	p = genome.mutationRates["bias"]
	while p > 0 do
		if math.random() < p then
			linkMutate(genome, true)
		end
		p = p - 1
	end

	p = genome.mutationRates["node"]
	while p > 0 do
		if math.random() < p then
			nodeMutate(genome)
		end
		p = p - 1
	end

	p = genome.mutationRates["enable"]
	while p > 0 do
		if math.random() < p then
			enableDisableMutate(genome, true)
		end
		p = p - 1
	end

	p = genome.mutationRates["disable"]
	while p > 0 do
		if math.random() < p then
			enableDisableMutate(genome, false)
		end
		p = p - 1
	end
end

function disjoint(genes1, genes2)
	local i1 = {}
	for i = 1,#genes1 do
		local gene = genes1[i]
		i1[gene.innovation] = true
	end

	local i2 = {}
	for i = 1,#genes2 do
		local gene = genes2[i]
		i2[gene.innovation] = true
	end

	local disjointGenes = 0
	for i = 1,#genes1 do
		local gene = genes1[i]
		if not i2[gene.innovation] then
			disjointGenes = disjointGenes+1
		end
	end

	for i = 1,#genes2 do
		local gene = genes2[i]
		if not i1[gene.innovation] then
			disjointGenes = disjointGenes+1
		end
	end

	local n = math.max(#genes1, #genes2)

	return disjointGenes / n
end

function weights(genes1, genes2)
	local i2 = {}
	for i = 1,#genes2 do
		local gene = genes2[i]
		i2[gene.innovation] = gene
	end

	local sum = 0
	local coincident = 0
	for i = 1,#genes1 do
		local gene = genes1[i]
		if i2[gene.innovation] ~= nil then
			local gene2 = i2[gene.innovation]
			sum = sum + math.abs(gene.weight - gene2.weight)
			coincident = coincident + 1
		end
	end

	return sum / coincident
end

function sameSpecies(genome1, genome2)
	local dd = DeltaDisjoint*disjoint(genome1.genes, genome2.genes)
	local dw = DeltaWeights*weights(genome1.genes, genome2.genes)
	return dd + dw < DeltaThreshold
end

function rankGlobally()
	local global = {}
	for s = 1,#pool.species do
		local species = pool.species[s]
		for g = 1,#species.genomes do
			table.insert(global, species.genomes[g])
		end
	end
	table.sort(global, function (a,b)
		return (a.fitness < b.fitness)
	end)

	for g=1,#global do
		global[g].globalRank = g
	end
end

function calculateAverageFitness(species)
	local total = 0

	for g=1,#species.genomes do
		local genome = species.genomes[g]
		total = total + genome.globalRank
	end

	species.averageFitness = total / #species.genomes
end

function totalAverageFitness()
	local total = 0
	for s = 1,#pool.species do
		local species = pool.species[s]
		total = total + species.averageFitness
	end

	return total
end

function cullSpecies(cutToOne)
	for s = 1,#pool.species do
		local species = pool.species[s]

		table.sort(species.genomes, function (a,b)
			return (a.fitness > b.fitness)
		end)

		local remaining = math.ceil(#species.genomes/2)
		if cutToOne then
			remaining = 1
		end
		while #species.genomes > remaining do
			table.remove(species.genomes)
		end
	end
end

function breedChild(species)
	local child = {}
	if math.random() < CrossoverChance then
		g1 = species.genomes[math.random(1, #species.genomes)]
		g2 = species.genomes[math.random(1, #species.genomes)]
		child = crossover(g1, g2)
	else
		g = species.genomes[math.random(1, #species.genomes)]
		child = copyGenome(g)
	end

	mutate(child)

	return child
end

function removeStaleSpecies()
	local survived = {}

	for s = 1,#pool.species do
		local species = pool.species[s]

		table.sort(species.genomes, function (a,b)
			return (a.fitness > b.fitness)
		end)

		if species.genomes[1].fitness > species.topFitness then
			species.topFitness = species.genomes[1].fitness
			species.staleness = 0
		else
			species.staleness = species.staleness + 1
		end
		if species.staleness < StaleSpecies or species.topFitness >= pool.maxFitness then
			table.insert(survived, species)
		end
	end

	pool.species = survived
end

function removeWeakSpecies()
	local survived = {}

	local sum = totalAverageFitness()
	for s = 1,#pool.species do
		local species = pool.species[s]
		breed = math.floor(species.averageFitness / sum * Population)
		if breed >= 1 then
			table.insert(survived, species)
		end
	end

	pool.species = survived
end


function addToSpecies(child)
	local foundSpecies = false
	for s=1,#pool.species do
		local species = pool.species[s]
		if not foundSpecies and sameSpecies(child, species.genomes[1]) then
			table.insert(species.genomes, child)
			foundSpecies = true
		end
	end

	if not foundSpecies then
		local childSpecies = newSpecies()
		table.insert(childSpecies.genomes, child)
		table.insert(pool.species, childSpecies)
	end
end

function newGeneration()
	cullSpecies(false) -- Cull the bottom half of each species
	rankGlobally()
	removeStaleSpecies()
	rankGlobally()
	for s = 1,#pool.species do
		local species = pool.species[s]
		calculateAverageFitness(species)
	end
	removeWeakSpecies()
	local sum = totalAverageFitness()
	local children = {}
	for s = 1,#pool.species do
		local species = pool.species[s]
		breed = math.floor(species.averageFitness / sum * Population) - 1
		for i=1,breed do
			table.insert(children, breedChild(species))
		end
	end
	cullSpecies(true) -- Cull all but the top member of each species
	while #children + #pool.species < Population do
		local species = pool.species[math.random(1, #pool.species)]
		table.insert(children, breedChild(species))
	end
	for c=1,#children do
		local child = children[c]
		addToSpecies(child)
	end

	pool.generation = pool.generation + 1

	writeFile("backup." .. pool.generation .. "." .. forms.gettext(saveLoadFile))
end

function initializePool()
	pool = newPool()

	for i=1,Population do
		basic = basicGenome()
		addToSpecies(basic)
	end

	initializeRun()
end

function clearJoypad()
	controller = {}
	for b = 1,#ButtonNames do
		controller["P1 " .. ButtonNames[b]] = false
	end
	joypad.set(controller)
end

function initializeRun()
	savestate.load(Filename);
	rightmost = 0
	pool.currentFrame = 0
	timeout = TimeoutConstant
	clearJoypad()

	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	generateNetwork(genome)
	evaluateCurrent()
end

function evaluateCurrent()
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]

	inputs = getInputs()
	controller = evaluateNetwork(genome.network, inputs)

	if controller["P1 Left"] and controller["P1 Right"] then
		controller["P1 Left"] = false
		controller["P1 Right"] = false
	end
	if controller["P1 Up"] and controller["P1 Down"] then
		controller["P1 Up"] = false
		controller["P1 Down"] = false
	end

	joypad.set(controller)
end

if pool == nil then
	initializePool()
end


function nextGenome()
	pool.currentGenome = pool.currentGenome + 1
	if pool.currentGenome > #pool.species[pool.currentSpecies].genomes then
		pool.currentGenome = 1
		pool.currentSpecies = pool.currentSpecies+1
		if pool.currentSpecies > #pool.species then
			newGeneration()
			pool.currentSpecies = 1
		end
	end
end

function fitnessAlreadyMeasured()
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]

	return genome.fitness ~= 0
end

function displayGenome(genome)
	local network = genome.network
	local cells = {}
	local i = 1
	local cell = {}
	for dy=-BoxRadius,BoxRadius do
		for dx=-BoxRadius,BoxRadius do
			cell = {}
			cell.x = 50+5*dx
			cell.y = 70+5*dy
			cell.value = network.neurons[i].value
			cells[i] = cell
			i = i + 1
		end
	end
	local biasCell = {}
	biasCell.x = 80
	biasCell.y = 110
	biasCell.value = network.neurons[Inputs].value
	cells[Inputs] = biasCell

	for o = 1,Outputs do
		cell = {}
		cell.x = 220
		cell.y = 30 + 8 * o
		cell.value = network.neurons[MaxNodes + o].value
		cells[MaxNodes+o] = cell
		local color
		if cell.value > 0 then
			color = 0xFF0000FF
		else
			color = 0xFF000000
		end
		gui.drawText(223, 24+8*o, ButtonNames[o], color, 9)
	end

	for n,neuron in pairs(network.neurons) do
		cell = {}
		if n > Inputs and n <= MaxNodes then
			cell.x = 140
			cell.y = 40
			cell.value = neuron.value
			cells[n] = cell
		end
	end

	for n=1,4 do
		for _,gene in pairs(genome.genes) do
			if gene.enabled then
				local c1 = cells[gene.into]
				local c2 = cells[gene.out]
				if gene.into > Inputs and gene.into <= MaxNodes then
					c1.x = 0.75*c1.x + 0.25*c2.x
					if c1.x >= c2.x then
						c1.x = c1.x - 40
					end
					if c1.x < 90 then
						c1.x = 90
					end

					if c1.x > 220 then
						c1.x = 220
					end
					c1.y = 0.75*c1.y + 0.25*c2.y

				end
				if gene.out > Inputs and gene.out <= MaxNodes then
					c2.x = 0.25*c1.x + 0.75*c2.x
					if c1.x >= c2.x then
						c2.x = c2.x + 40
					end
					if c2.x < 90 then
						c2.x = 90
					end
					if c2.x > 220 then
						c2.x = 220
					end
					c2.y = 0.25*c1.y + 0.75*c2.y
				end
			end
		end
	end
	-- where the box gets drawn
	-- looks like 'cells' is where the information for white/black tiles are
	gui.drawBox(50-BoxRadius*5-3,70-BoxRadius*5-3,50+BoxRadius*5+2,70+BoxRadius*5+2,0xFF000000, 0x80808080)

	-- this part specifically draw the cells in the box
	for n,cell in pairs(cells) do
		if n > Inputs or cell.value ~= 0 then
			local color = math.floor((cell.value+1)/2*256)
			if color > 255 then color = 255 end
			if color < 0 then color = 0 end
			local opacity = 0xFF000000
			if cell.value == 0 then
				opacity = 0x50000000
			end
			color = opacity + color*0x10000 + color*0x100 + color
			gui.drawBox(cell.x-2,cell.y-2,cell.x+2,cell.y+2,opacity,color)
		end
	end
	for _,gene in pairs(genome.genes) do
		if gene.enabled then
			local c1 = cells[gene.into]
			local c2 = cells[gene.out]
			local opacity = 0xA0000000
			if c1.value == 0 then
				opacity = 0x20000000
			end

			local color = 0x80-math.floor(math.abs(sigmoid(gene.weight))*0x80)
			if gene.weight > 0 then
				color = opacity + 0x8000 + 0x10000*color
			else
				color = opacity + 0x800000 + 0x100*color
			end
			gui.drawLine(c1.x+1, c1.y, c2.x-3, c2.y, color)
		end
	end

	gui.drawBox(49,71,51,78,0x00000000,0x80FF0000)

	if forms.ischecked(showMutationRates) then
		local pos = 100
		for mutation,rate in pairs(genome.mutationRates) do
			gui.drawText(100, pos, mutation .. ": " .. rate, 0xFF000000, 10)
			pos = pos + 8
		end
	end
end

function writeFile(filename)
        local file = io.open(filename, "w")
	file:write(pool.generation .. "\n")
	file:write(pool.maxFitness .. "\n")
	file:write(#pool.species .. "\n")
        for n,species in pairs(pool.species) do
		file:write(species.topFitness .. "\n")
		file:write(species.staleness .. "\n")
		file:write(#species.genomes .. "\n")
		for m,genome in pairs(species.genomes) do
			file:write(genome.fitness .. "\n")
			file:write(genome.maxneuron .. "\n")
			for mutation,rate in pairs(genome.mutationRates) do
				file:write(mutation .. "\n")
				file:write(rate .. "\n")
			end
			file:write("done\n")

			file:write(#genome.genes .. "\n")
			for l,gene in pairs(genome.genes) do
				file:write(gene.into .. " ")
				file:write(gene.out .. " ")
				file:write(gene.weight .. " ")
				file:write(gene.innovation .. " ")
				if(gene.enabled) then
					file:write("1\n")
				else
					file:write("0\n")
				end
			end
		end
        end
        file:close()
end

function savePool()
	local filename = forms.gettext(saveLoadFile)
	writeFile(filename)
end

function loadFile(filename)
        local file = io.open(filename, "r")
	pool = newPool()
	pool.generation = file:read("*number")
	pool.maxFitness = file:read("*number")
	forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
        local numSpecies = file:read("*number")
        for s=1,numSpecies do
		local species = newSpecies()
		table.insert(pool.species, species)
		species.topFitness = file:read("*number")
		species.staleness = file:read("*number")
		local numGenomes = file:read("*number")
		for g=1,numGenomes do
			local genome = newGenome()
			table.insert(species.genomes, genome)
			genome.fitness = file:read("*number")
			genome.maxneuron = file:read("*number")
			local line = file:read("*line")
			while line ~= "done" do
				genome.mutationRates[line] = file:read("*number")
				line = file:read("*line")
			end
			local numGenes = file:read("*number")
			for n=1,numGenes do
				local gene = newGene()
				table.insert(genome.genes, gene)
				local enabled
				gene.into, gene.out, gene.weight, gene.innovation, enabled = file:read("*number", "*number", "*number", "*number", "*number")
				if enabled == 0 then
					gene.enabled = false
				else
					gene.enabled = true
				end

			end
		end
	end
        file:close()

	while fitnessAlreadyMeasured() do
		nextGenome()
	end
	initializeRun()
	pool.currentFrame = pool.currentFrame + 1
end

function playTop()
	local maxfitness = 0
	local maxs, maxg
	for s,species in pairs(pool.species) do
		for g,genome in pairs(species.genomes) do
			if genome.fitness > maxfitness then
				maxfitness = genome.fitness
				maxs = s
				maxg = g
			end
		end
	end

	pool.currentSpecies = maxs
	pool.currentGenome = maxg
	pool.maxFitness = maxfitness
	forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
	initializeRun()
	pool.currentFrame = pool.currentFrame + 1
	return
end

function onExit()
	forms.destroy(form)
end

writeFile("temp.pool")

event.onexit(onExit)

form = forms.newform(200, 260, "Fitness")
maxFitnessLabel = forms.label(form, "Max Fitness: " .. math.floor(pool.maxFitness), 5, 8)
showNetwork = forms.checkbox(form, "Show Map", 5, 30)
showMutationRates = forms.checkbox(form, "Show M-Rates", 5, 52)
restartButton = forms.button(form, "Restart", initializePool, 5, 77)
saveButton = forms.button(form, "Save", savePool, 5, 102)
loadButton = forms.button(form, "Load", loadPool, 80, 102)
saveLoadFile = forms.textbox(form, Filename .. ".pool", 170, 25, nil, 5, 148)
saveLoadLabel = forms.label(form, "Save/Load:", 5, 129)
playTopButton = forms.button(form, "Play Top", playTop, 5, 170)
hideBanner = forms.checkbox(form, "Hide Banner", 5, 190)


-- current health variable
lastHealth = memory.readbyte(0x0bcf)
-- life counter
lastLife = 0
-- ouch animation
decrement = 0
-- megaman is alive
dead = false
-- megaman's last X position
lastX = 0
xMoved = false
-- the camera's last position
lastCamX = 0
camMoved = false
-- reset of too negative
tooNegative = false
-- keeps track of current rightmost
rIndex = 0
-- reset
reset = false


lastLife = memory.read_s16_le(0x1f90)
--------------------------------------------------------------------------------------------
-- This is where the action starts!
--------------------------------------------------------------------------------------------

while true do
	local backgroundColor = 0xD0FFFFFF
	if not forms.ischecked(hideBanner) then
		gui.drawBox(0, 0, 300, 26, backgroundColor, backgroundColor)
	end

	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	---------------------------------------------------------------------------------------
	--this displays neural network and its connections
	if forms.ischecked(showNetwork) then
		displayGenome(genome)
	end
	---------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------
	-- unsure what this does.  it looks like it is attempting to get the right genome
	-- controller set
	if pool.currentFrame%5 == 0 then
		evaluateCurrent()
	end

	joypad.set(controller)
	---------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------
	-- gets how far right it has moved
	getPositions()

	---------------------------------------------------------------------------------------
	-- checking if died
	-- note: this doesn't work. T-T
	-- if memory.read_s16_le(0x1f90) < lastLife then
		-- rightmost.insert(#rightmost, 0)
	-- end

	-- if current position is greater than right most than reset timeconstant and
	-- set rightmost to current position.
	-- this needs to be changed for Mega Man X
	---- is there an enemy on the screen?
	---- is the camera's position not moving?
	---- check x's last position in relation to his current
	---- has he moved? ok now check the camera
	---- has it moved? ok if both are moving then reset time
	--
	-- if camX ~= lastCamX then
		-- print(camX)
		-- lastCamX = camX
		-- camMoved = true
	-- else
		-- camMoved = false
	-- end
	-- if megaX ~= lastX then
		-- if megaX > lastX then
			-- rightmost[rIndex] = megaX
			-- timeout = TimeoutConstant
		-- elseif not camMoved then
			-- timeout = TimeoutConstant
		-- end
	-- end

	if memory.read_s16_le(0x1f90) < lastLife then
		lastX = megaX
		timeout = TimeoutConstant
		lastLife = memory.read_s16_le(0x1f90)
	elseif megaX ~= lastX then
		if megaX > lastX then
			rightmost = rightmost + (megaX - lastX)
			lastX = megaX
			timeout = TimeoutConstant
		end
	end
	---------------------------------------------------------------------------------------
	--- 1936 ?
	--- something weird happened at 1941
	--- 1942 - charge up animation?
	if memory.read_s16_le(0x1942) > 0 then
		-- print("boom")
	end
	timeout = timeout - 1


	---------------------------------------------------------------------------------------
	-- checking if current health is the same as last health
	local health = memory.readbyte(0x0bcf)
	if(health < lastHealth) then
		decrement = decrement + (lastHealth - health)

		print("last"..lastHealth)
		print("h"..health)
		print("decre"..decrement)
	elseif (health > lastHealth) then
		decrement = decrement - (lastHealth - health)
	end
	-- decrement = lastHealth - health
	if(memory.readbyte(0x0bcf) <= 16) then
		lastHealth = memory.readbyte(0x0bcf)
	end

	---------------------------------------------------------------------------------------
	-- is megaman alive?
	dead = (lastHealth == 0) and (lastLife == 0)


	local timeoutBonus = pool.currentFrame / 4

	local total = 0

	-- for i = 0,#rightmost do
		-- total = total + rightmost[i]
	-- end

	-- is Mega Man X just STANDING there.. -_-
	if math.floor(total - (pool.currentFrame) / 2 - (timeout + timeoutBonus)*2/3) < -250 then
		tooNegative = true
		print("bingo")
	else
		tooNegative = false
	end

	---------------------------------------------------------------------------------------
	-- it looks as though the following if statement determines if megaman is moving
	-- forward consistently.  If there is a stop, or, say, he is jumping on a wall and
	-- moving up but not forward, then the genome is reset
	---------------------------------------------------------------------------------------
	if dead or tooNegative or timeout + timeoutBonus <= 0 then
		-- print("Timeout"..timeout)
		-- print("Bonus"..timeoutBonus)
		-- print("Constant"..TimeoutConstant)

		total = rightmost - decrement
		print("R"..rightmost)
		print("D"..decrement)
		decrement = 0
		local fitness = total - pool.currentFrame / 2
		lastHealth = 0
		-- the following code looks like it was more useful for Super Mario World

		-- if gameinfo.getromname() == "Mega Man X (USA)" and rightmost > 4816 then
			-- fitness = fitness + 1000
		-- end

		-- maybe here... honestly don't know what I meant here.. -_-
		if total == 0 then
			total = -1
		end
		genome.fitness = total

		if fitness > pool.maxFitness then
			pool.maxFitness = total
			forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
			writeFile("backup." .. pool.generation .. "." .. forms.gettext(saveLoadFile))
		end

		console.writeline("Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " fitness: " .. total)
		pool.currentSpecies = 1
		pool.currentGenome = 1

		-- this moves to the next genome
		-- makes sense!
		while fitnessAlreadyMeasured() do
			nextGenome()
		end
		initializeRun()
	end
	---------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------
	local measured = 0
	local total = 0
	for _,species in pairs(pool.species) do
		for _,genome in pairs(species.genomes) do
			total = total + 1
			if genome.fitness ~= 0 then
				measured = measured + 1
			end
		end
	end
	if not forms.ischecked(hideBanner) then
		gui.drawText(0, 0, "Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " (" .. math.floor(measured/total*100) .. "%)", 0xFF000000, 11)
		gui.drawText(0, 12, "Fitness: " .. math.floor(rightmost - pool.currentFrame / 2), 0xFF000000, 11)
		gui.drawText(100, 12, "Max Fitness: " .. math.floor(pool.maxFitness), 0xFF000000, 11)
	end

	pool.currentFrame = pool.currentFrame + 1

	emu.frameadvance();
end
