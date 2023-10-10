class Request < ApplicationRecord
	enum status: {pending:0, accepted:1, rejected:2}
end
